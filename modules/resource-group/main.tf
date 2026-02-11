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

resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

locals {
  rg_id       = azurerm_resource_group.this.id
  rg_name     = azurerm_resource_group.this.name
  rg_location = azurerm_resource_group.this.location
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
