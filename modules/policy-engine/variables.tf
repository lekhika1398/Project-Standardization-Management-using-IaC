variable "org_prefix" {
  description = "Organization prefix used in generated policy names and default parameters."
  type        = string
}

variable "environment" {
  description = "Environment short name used in generated policy names and default parameters."
  type        = string
}

variable "region_code" {
  description = "Region code used in default naming policy parameters."
  type        = string
}

variable "policy_scope_type" {
  description = "Policy assignment scope type."
  type        = string
}

variable "subscription_scope_id" {
  description = "Resolved subscription scope id."
  type        = string
}

variable "resource_group_scope_id" {
  description = "Resolved resource group scope id."
  type        = string
}

variable "management_group_scope_id" {
  description = "Resolved management group scope id or null."
  type        = string
  default     = null
}

variable "policy_assignment_location" {
  description = "Assignment location required for specific scope types."
  type        = string
  default     = "eastus"
}

variable "policy_assignment_parameters" {
  description = "Optional per-policy parameter overrides keyed by policy folder name."
  type        = map(map(any))
  default     = {}
}

variable "policies_path" {
  description = "Absolute path to policies directory."
  type        = string
}
