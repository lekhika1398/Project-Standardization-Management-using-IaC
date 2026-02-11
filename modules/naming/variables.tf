variable "org_prefix" {
  description = "Organization prefix segment."
  type        = string
}

variable "environment" {
  description = "Environment segment."
  type        = string
}

variable "resource_type" {
  description = "Resource type segment."
  type        = string
}

variable "region_code" {
  description = "Region segment."
  type        = string
}

variable "instance" {
  description = "Optional instance segment."
  type        = string
  default     = ""
}
