resource "azurerm_policy_definition" "this" {
  for_each = local.policy_properties

  name         = lower(substr(replace("${var.org_prefix}-${var.environment}-${each.key}", "_", "-"), 0, 64))
  policy_type  = "Custom"
  mode         = try(each.value.mode, "Indexed")
  display_name = try(each.value.displayName, title(replace(each.key, "-", " ")))
  description  = try(each.value.description, null)

  metadata = try(each.value.metadata, null) != null ? jsonencode(each.value.metadata) : null

  policy_rule = jsonencode(try(jsondecode(local.policy_definition_raw[each.key]).properties.policyRule, {}))
  parameters  = length(try(each.value.parameters, {})) > 0 ? jsonencode(each.value.parameters) : null
}
