# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

# ADLS Gen2
output "adls_account_name" {
  description = "ADLS Gen2 storage account name"
  value       = azurerm_storage_account.adls.name
}

output "adls_primary_dfs_endpoint" {
  description = "ADLS Gen2 DFS (Data Lake) endpoint"
  value       = azurerm_storage_account.adls.primary_dfs_endpoint
}

output "adls_filesystems" {
  description = "ADLS Gen2 filesystem (container) names"
  value       = ["raw", "processed", "curated"]
}

# Azure Functions
output "function_app_name" {
  description = "Azure Function App name"
  value       = azurerm_linux_function_app.func.name
}

output "function_app_default_hostname" {
  description = "Default hostname of the Function App"
  value       = azurerm_linux_function_app.func.default_hostname
}

output "function_app_principal_id" {
  description = "Managed identity principal ID of the Function App"
  value       = azurerm_linux_function_app.func.identity[0].principal_id
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.func_insights.connection_string
  sensitive   = true
}

# Azure AI Foundry
output "ai_foundry_name" {
  description = "Azure AI Foundry hub name"
  value       = azurerm_ai_foundry.foundry.name
}

output "ai_foundry_project_name" {
  description = "Azure AI Foundry project name"
  value       = azurerm_ai_foundry_project.project.name
}

output "ai_foundry_principal_id" {
  description = "Managed identity principal ID of the AI Foundry hub"
  value       = azurerm_ai_foundry.foundry.identity[0].principal_id
}

output "key_vault_uri" {
  description = "Key Vault URI used by AI Foundry"
  value       = azurerm_key_vault.ai_kv.vault_uri
}
