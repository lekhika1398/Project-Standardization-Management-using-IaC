variable "rg_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure location for resource group."
  type        = string
}

variable "tags" {
  description = "Tags applied to the resource group."
  type        = map(string)
  default     = {}
}

resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

output "id" {
  description = "Resource group ID."
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Resource group name."
  value       = azurerm_resource_group.this.name
}
