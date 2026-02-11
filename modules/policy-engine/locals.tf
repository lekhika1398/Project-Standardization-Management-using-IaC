locals {
  policy_definition_files = fileset(var.policies_path, "*/definition.json")

  policy_definition_raw = {
    for definition_file in local.policy_definition_files :
    dirname(definition_file) => file("${var.policies_path}/${definition_file}")
  }

  policy_definition_documents = {
    for policy_key, definition_raw in local.policy_definition_raw :
    policy_key => jsondecode(definition_raw)
  }

  policy_properties = {
    for policy_key, definition_document in local.policy_definition_documents :
    policy_key => try(definition_document.properties, {})
  }

  default_policy_assignment_parameters = {
    naming = {
      orgPrefix   = var.org_prefix
      environment = var.environment
      regionCode  = var.region_code
      effect      = "Deny"
    }
    tagging = {
      effect = "Deny"
    }
  }

  effective_policy_assignment_parameters = merge(local.default_policy_assignment_parameters, var.policy_assignment_parameters)

  assignment_parameters_json = {
    for policy_key, properties in local.policy_properties :
    policy_key => (
      length(try(properties.parameters, {})) == 0
      ? null
      : jsonencode({
          for parameter_name, parameter_definition in try(properties.parameters, {}) :
          parameter_name => {
            value = (
              contains(keys(lookup(local.effective_policy_assignment_parameters, policy_key, {})), parameter_name)
              ? lookup(local.effective_policy_assignment_parameters[policy_key], parameter_name, null)
              : try(parameter_definition.defaultValue, null)
            )
          }
          if (
            contains(keys(lookup(local.effective_policy_assignment_parameters, policy_key, {})), parameter_name) ||
            can(parameter_definition.defaultValue)
          )
        })
    )
  }

  policy_scope = (
    var.policy_scope_type == "resource_group" ? var.resource_group_scope_id :
    var.policy_scope_type == "subscription" ? var.subscription_scope_id :
    var.management_group_scope_id
  )
}
