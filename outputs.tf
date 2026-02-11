output "policy_scope" {
  description = "Resolved scope where governance policies are assigned."
  value       = local.policy_scope
}

output "policy_definition_ids" {
  description = "Custom policy definition IDs by policy key."
  value = {
    for policy_key, definition in azurerm_policy_definition.this :
    policy_key => definition.id
  }
}

output "policy_assignment_ids" {
  description = "Policy assignment IDs by policy key for the selected scope type."
  value = merge(
    { for policy_key, assignment in azurerm_resource_group_policy_assignment.this : policy_key => assignment.id },
    { for policy_key, assignment in azurerm_subscription_policy_assignment.this : policy_key => assignment.id },
    { for policy_key, assignment in azurerm_management_group_policy_assignment.this : policy_key => assignment.id }
  )
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
  value       = module.governance_resource_group.app_service_name
}

output "free_app_service_id" {
  description = "Free App Service ID when deployment is enabled."
  value       = module.governance_resource_group.app_service_id
}
