terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

# -----------------------------------------
# Resource Group
# -----------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------
# Azure Data Lake Storage Gen2 (ADLS)
# -----------------------------------------
resource "azurerm_storage_account" "adls" {
  name                     = "adls${var.project_name}${var.environment}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true # Enables Data Lake Storage Gen2

  blob_properties {
    versioning_enabled = true
  }

  tags = local.common_tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "raw" {
  name               = "raw"
  storage_account_id = azurerm_storage_account.adls.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "processed" {
  name               = "processed"
  storage_account_id = azurerm_storage_account.adls.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "curated" {
  name               = "curated"
  storage_account_id = azurerm_storage_account.adls.id
}

# -----------------------------------------
# Azure Functions
# -----------------------------------------
resource "azurerm_storage_account" "func_storage" {
  name                     = "stfunc${var.project_name}${var.environment}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

resource "azurerm_application_insights" "func_insights" {
  name                = "appi-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"

  tags = local.common_tags
}

resource "azurerm_service_plan" "func_plan" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption plan

  tags = local.common_tags
}

resource "azurerm_linux_function_app" "func" {
  name                       = "func-${var.project_name}-${var.environment}"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  service_plan_id            = azurerm_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.func_insights.instrumentation_key
    ADLS_ACCOUNT_NAME              = azurerm_storage_account.adls.name
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Grant Function App access to ADLS
resource "azurerm_role_assignment" "func_adls_access" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.func.identity[0].principal_id
}

# -----------------------------------------
# Azure AI Foundry
# -----------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "ai_kv" {
  name                = "kv-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  tags = local.common_tags
}

resource "azurerm_storage_account" "ai_storage" {
  name                     = "stai${var.project_name}${var.environment}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

resource "azurerm_ai_foundry" "foundry" {
  name                = "aif-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  storage_account_id  = azurerm_storage_account.ai_storage.id
  key_vault_id        = azurerm_key_vault.ai_kv.id

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

resource "azurerm_ai_foundry_project" "project" {
  name               = "aifp-${var.project_name}-${var.environment}"
  location           = azurerm_ai_foundry.foundry.location
  ai_services_hub_id = azurerm_ai_foundry.foundry.id

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Grant AI Foundry access to its storage
resource "azurerm_role_assignment" "ai_storage_access" {
  scope                = azurerm_storage_account.ai_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_ai_foundry.foundry.identity[0].principal_id
}

# Grant AI Foundry access to Key Vault
resource "azurerm_key_vault_access_policy" "ai_kv_policy" {
  key_vault_id = azurerm_key_vault.ai_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_ai_foundry.foundry.identity[0].principal_id

  secret_permissions      = ["Get", "List", "Set", "Delete"]
  key_permissions         = ["Get", "List", "Create", "Delete"]
  certificate_permissions = ["Get", "List"]
}
