output "policy_scope" {
  description = "Resolved scope where governance policies are assigned."
  value       = module.policy_engine.policy_scope
}

output "policy_definition_ids" {
  description = "Custom policy definition IDs by policy key."
  value       = module.policy_engine.policy_definition_ids
}

output "policy_assignment_ids" {
  description = "Policy assignment IDs by policy key for the selected scope type."
  value       = module.policy_engine.policy_assignment_ids
}

output "governance_resource_group_name" {
  description = "Governance resource group name."
  value       = module.governance_resource_group.name
}

output "governance_resource_group_id" {
  description = "Governance resource group ID."
  value       = module.governance_resource_group.id
}

output "free_app_service_name" {
  description = "Free App Service name when deployment is enabled."
  value       = module.governance_app_service.app_service_name
}

output "free_app_service_id" {
  description = "Free App Service ID when deployment is enabled."
  value       = module.governance_app_service.app_service_id
}
