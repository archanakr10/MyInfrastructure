variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Short project name used in resource naming (lowercase, no special chars)"
  type        = string
  default     = "myinfra"

  validation {
    condition     = can(regex("^[a-z0-9]{1,10}$", var.project_name))
    error_message = "project_name must be lowercase alphanumeric and max 10 characters (storage account name limits)."
  }
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "func_python_version" {
  description = "Python runtime version for Azure Function App"
  type        = string
  default     = "3.11"
}

variable "log_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30
}
