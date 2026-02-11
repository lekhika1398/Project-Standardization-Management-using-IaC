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

output "deployment_resource_group_name" {
  description = "Deployment resource group name."
  value       = module.deployment_resource_group.name
}

output "deployment_resource_group_id" {
  description = "Deployment resource group ID."
  value       = module.deployment_resource_group.id
}

output "app_service_name" {
  description = "App Service name when deployment is enabled."
  value       = module.app_service.app_service_name
}

output "app_service_id" {
  description = "App Service ID when deployment is enabled."
  value       = module.app_service.app_service_id
}
