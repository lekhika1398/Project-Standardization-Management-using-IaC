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
  description = "Subscription policy assignment IDs by policy key."
  value = {
    for policy_key, assignment in azurerm_subscription_policy_assignment.this :
    policy_key => assignment.id
  }
}

output "generated_resource_group_name" {
  description = "Generated resource group name from naming module."
  value       = module.naming_resource_group.resource_name
}

output "sample_resource_group_id" {
  description = "Sample resource group ID when deployment is enabled."
  value       = var.deploy_sample_resource_group ? module.sample_resource_group[0].id : null
}
