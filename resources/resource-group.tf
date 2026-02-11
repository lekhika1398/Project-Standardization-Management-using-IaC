variable "create_resource_group" {
  description = "When true, create the resource group; when false, reference an existing resource group."
  type        = bool
  default     = true
}

variable "rg_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure location for resource group creation."
  type        = string
}

variable "tags" {
  description = "Tags applied to managed resources."
  type        = map(string)
  default     = {}
}

variable "deploy_free_app_service" {
  description = "When true, deploy a free tier App Service Plan and Web App."
  type        = bool
  default     = true
}

variable "app_service_name" {
  description = "Globally unique name for the App Service."
  type        = string
}

data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1
  name  = var.rg_name
}

resource "azurerm_resource_group" "this" {
  count = var.create_resource_group ? 1 : 0

  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

locals {
  rg_id       = var.create_resource_group ? azurerm_resource_group.this[0].id : data.azurerm_resource_group.existing[0].id
  rg_name     = var.create_resource_group ? azurerm_resource_group.this[0].name : data.azurerm_resource_group.existing[0].name
  rg_location = var.create_resource_group ? azurerm_resource_group.this[0].location : data.azurerm_resource_group.existing[0].location

  normalized_rg_name = lower(replace(local.rg_name, "_", "-"))
}

resource "azurerm_service_plan" "free" {
  count = var.deploy_free_app_service ? 1 : 0

  name                = substr("${local.normalized_rg_name}-asp-f1", 0, 60)
  location            = local.rg_location
  resource_group_name = local.rg_name
  os_type             = "Windows"
  sku_name            = "F1"
  tags                = var.tags
}

resource "azurerm_windows_web_app" "free" {
  count = var.deploy_free_app_service ? 1 : 0

  name                = var.app_service_name
  location            = local.rg_location
  resource_group_name = local.rg_name
  service_plan_id     = azurerm_service_plan.free[0].id
  https_only          = true
  tags                = var.tags

  site_config {}
}

output "id" {
  description = "Resource group ID."
  value       = local.rg_id
}

output "name" {
  description = "Resource group name."
  value       = local.rg_name
}

output "app_service_name" {
  description = "App Service name when deployed."
  value       = var.deploy_free_app_service ? azurerm_windows_web_app.free[0].name : null
}

output "app_service_id" {
  description = "App Service ID when deployed."
  value       = var.deploy_free_app_service ? azurerm_windows_web_app.free[0].id : null
}
