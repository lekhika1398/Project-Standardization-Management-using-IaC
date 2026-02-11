variable "subscription_id" {
  description = "Target Azure subscription ID. Leave empty to use the authenticated subscription context."
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
  description = "Azure location used for deployable resources and policy assignments."
  type        = string
}

variable "policy_assignment_location" {
  description = "Location for subscription policy assignments."
  type        = string
  default     = "eastus"
}

variable "mandatory_tags" {
  description = "Mandatory tags used on sample resources."
  type        = list(string)
  default     = ["Environment", "Owner"]
}

variable "default_tags" {
  description = "Default tags merged onto sample resources."
  type        = map(string)
  default     = {}
}

variable "policy_assignment_parameters" {
  description = "Optional per-policy assignment parameter overrides, keyed by policy folder name."
  type        = map(map(any))
  default     = {}
}

variable "deploy_sample_resource_group" {
  description = "When true, deploys a sample resource group to validate governance controls."
  type        = bool
  default     = true
}

variable "resource_group_instance" {
  description = "Optional naming instance suffix for the sample resource group."
  type        = string
  default     = "001"
}
