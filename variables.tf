variable "subscription_id" {
  description = "Target Azure subscription ID. Leave empty to use the authenticated context."
  type        = string
  default     = ""
}

variable "org_prefix" {
  description = "Organization prefix used by policy and naming standards."
  type        = string
}

variable "environment" {
  description = "Environment short name (for example: dev, test, prod)."
  type        = string
}

variable "region_code" {
  description = "Short region code used in naming convention (for example: eus2)."
  type        = string
}

variable "location" {
  description = "Azure location for deployable resources (resource group and app service)."
  type        = string
}

variable "policy_scope_type" {
  description = "Policy assignment scope type. Allowed values: resource_group, subscription, management_group."
  type        = string
  default     = "resource_group"

  validation {
    condition     = contains(["resource_group", "subscription", "management_group"], var.policy_scope_type)
    error_message = "policy_scope_type must be one of: resource_group, subscription, management_group."
  }
}

variable "management_group_id" {
  description = "Management group ID (required when policy_scope_type is management_group)."
  type        = string
  default     = ""
}

variable "policy_assignment_location" {
  description = "Location for policy assignments where a location is required."
  type        = string
  default     = "eastus"
}

variable "create_governance_resource_group" {
  description = "When true, create the governance resource group; when false, use an existing one."
  type        = bool
  default     = true
}

variable "governance_resource_group_name" {
  description = "Resource group name used for governance resources and optional resource-group assignment scope."
  type        = string
  default     = "Lekhika_RG"
}

variable "mandatory_tags" {
  description = "Mandatory tags used on managed resources."
  type        = list(string)
  default     = ["Environment", "Owner"]
}

variable "default_tags" {
  description = "Default tags merged onto managed resources."
  type        = map(string)
  default     = {}
}

variable "policy_assignment_parameters" {
  description = "Optional per-policy assignment parameter overrides, keyed by policy folder name."
  type        = map(map(any))
  default     = {}
}

variable "deploy_free_app_service" {
  description = "When true, deploy an App Service Plan and Web App in the governance resource group."
  type        = bool
  default     = true
}

variable "app_service_plan_sku_name" {
  description = "App Service plan SKU name (for example: F1, B1, S1)."
  type        = string
  default     = "B1"
}

variable "app_service_name_prefix" {
  description = "Prefix used to build a globally unique App Service name."
  type        = string
  default     = "lekhika-webapp"
}
