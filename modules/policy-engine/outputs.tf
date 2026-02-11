output "policy_scope" {
  description = "Resolved policy assignment scope."
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
  description = "Policy assignment IDs by policy key for selected scope type."
  value = merge(
    { for policy_key, assignment in azurerm_resource_group_policy_assignment.this : policy_key => assignment.id },
    { for policy_key, assignment in azurerm_subscription_policy_assignment.this : policy_key => assignment.id },
    { for policy_key, assignment in azurerm_management_group_policy_assignment.this : policy_key => assignment.id }
  )
}
