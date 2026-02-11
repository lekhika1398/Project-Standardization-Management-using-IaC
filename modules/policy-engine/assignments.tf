resource "azurerm_resource_group_policy_assignment" "this" {
  for_each = var.policy_scope_type == "resource_group" ? azurerm_policy_definition.this : {}

  name                 = lower(substr(replace("${var.org_prefix}-${var.environment}-${each.key}-assignment", "_", "-"), 0, 64))
  display_name         = "${try(local.policy_properties[each.key].displayName, title(replace(each.key, "-", " ")))} Assignment"
  resource_group_id    = var.resource_group_scope_id
  policy_definition_id = each.value.id
  enforce              = true
  parameters           = lookup(local.assignment_parameters_json, each.key, null)
}

resource "azurerm_subscription_policy_assignment" "this" {
  for_each = var.policy_scope_type == "subscription" ? azurerm_policy_definition.this : {}

  name                 = lower(substr(replace("${var.org_prefix}-${var.environment}-${each.key}-assignment", "_", "-"), 0, 64))
  display_name         = "${try(local.policy_properties[each.key].displayName, title(replace(each.key, "-", " ")))} Assignment"
  subscription_id      = var.subscription_scope_id
  policy_definition_id = each.value.id
  enforce              = true
  location             = var.policy_assignment_location
  parameters           = lookup(local.assignment_parameters_json, each.key, null)
}

resource "azurerm_management_group_policy_assignment" "this" {
  for_each = var.policy_scope_type == "management_group" ? azurerm_policy_definition.this : {}

  name                 = lower(substr(replace("${var.org_prefix}-${var.environment}-${each.key}-assignment", "_", "-"), 0, 64))
  display_name         = "${try(local.policy_properties[each.key].displayName, title(replace(each.key, "-", " ")))} Assignment"
  management_group_id  = var.management_group_scope_id
  policy_definition_id = each.value.id
  enforce              = true
  location             = var.policy_assignment_location
  parameters           = lookup(local.assignment_parameters_json, each.key, null)
}
