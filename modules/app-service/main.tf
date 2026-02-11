variable "deploy" {
  description = "When true, deploy App Service Plan and Web App."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Resource group name for App Service resources."
  type        = string
}

variable "location" {
  description = "Azure location for App Service resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to App Service resources."
  type        = map(string)
  default     = {}
}

variable "app_service_name_prefix" {
  description = "Prefix used to build globally unique App Service name."
  type        = string
}

variable "environment" {
  description = "Environment short name used in generated names."
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID used to generate deterministic unique suffix."
  type        = string
}

locals {
  subscription_fragment = substr(replace(var.subscription_id, "-", ""), 0, 6)

  app_service_name = lower(substr(
    regexreplace("${var.app_service_name_prefix}-${var.environment}-${local.subscription_fragment}", "[^a-z0-9-]", ""),
    0,
    60
  ))

  normalized_rg_name = lower(replace(var.resource_group_name, "_", "-"))
}

resource "azurerm_service_plan" "free" {
  count = var.deploy ? 1 : 0

  name                = substr("${local.normalized_rg_name}-asp-f1", 0, 60)
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = "F1"
  tags                = var.tags
}

resource "azurerm_windows_web_app" "free" {
  count = var.deploy ? 1 : 0

  name                = local.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.free[0].id
  https_only          = true
  tags                = var.tags

  site_config {}
}

output "app_service_name" {
  description = "App Service name when deployed."
  value       = var.deploy ? azurerm_windows_web_app.free[0].name : null
}

output "app_service_id" {
  description = "App Service ID when deployed."
  value       = var.deploy ? azurerm_windows_web_app.free[0].id : null
}
