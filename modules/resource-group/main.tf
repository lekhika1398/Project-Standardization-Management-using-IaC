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
  description = "Tags applied to resource group when created by Terraform."
  type        = map(string)
  default     = {}
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
}

output "id" {
  description = "Resource group ID."
  value       = local.rg_id
}

output "name" {
  description = "Resource group name."
  value       = local.rg_name
}

output "location" {
  description = "Resource group location."
  value       = local.rg_location
}
