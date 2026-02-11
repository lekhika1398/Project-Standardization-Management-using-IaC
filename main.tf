data "azurerm_subscription" "current" {}

locals {
  policy_scope = var.subscription_id != "" ? "/subscriptions/${var.subscription_id}" : data.azurerm_subscription.current.id

  policy_definition_files = fileset("${path.module}/policies", "*/definition.json")

  policy_definition_raw = {
    for definition_file in local.policy_definition_files :
    dirname(definition_file) => file("${path.module}/policies/${definition_file}")
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
            value = contains(keys(lookup(local.effective_policy_assignment_parameters, policy_key, {})), parameter_name)
              ? lookup(local.effective_policy_assignment_parameters[policy_key], parameter_name, null)
              : try(parameter_definition.defaultValue, null)
          }
          if (
            contains(keys(lookup(local.effective_policy_assignment_parameters, policy_key, {})), parameter_name) ||
            can(parameter_definition.defaultValue)
          )
        })
    )
  }

  mandatory_tags_map = {
    for tag_name in var.mandatory_tags :
    tag_name => lookup(var.default_tags, tag_name, "required")
  }

  sample_resource_group_tags = merge(local.mandatory_tags_map, var.default_tags, {
    ManagedBy = "Terraform"
  })
}

resource "azurerm_policy_definition" "this" {
  for_each = local.policy_properties

  name         = lower(substr(replace("${var.org_prefix}-${var.environment}-${each.key}", "_", "-"), 0, 64))
  policy_type  = "Custom"
  mode         = try(each.value.mode, "Indexed")
  display_name = try(each.value.displayName, title(replace(each.key, "-", " ")))
  description  = try(each.value.description, null)

  metadata = try(each.value.metadata, null) != null ? jsonencode(each.value.metadata) : null

  # Policy rule and parameters are sourced from policy JSON files under policies/*.
  policy_rule = jsonencode(try(jsondecode(local.policy_definition_raw[each.key]).properties.policyRule, {}))
  parameters  = length(try(each.value.parameters, {})) > 0 ? jsonencode(each.value.parameters) : null
}

resource "azurerm_subscription_policy_assignment" "this" {
  for_each = azurerm_policy_definition.this

  name                 = lower(substr(replace("${var.org_prefix}-${var.environment}-${each.key}-assignment", "_", "-"), 0, 64))
  display_name         = "${try(local.policy_properties[each.key].displayName, title(replace(each.key, "-", " ")))} Assignment"
  subscription_id      = local.policy_scope
  policy_definition_id = each.value.id
  enforce              = true
  location             = var.policy_assignment_location
  parameters           = lookup(local.assignment_parameters_json, each.key, null)

  identity {
    type = "SystemAssigned"
  }
}

module "naming_resource_group" {
  source = "./modules/naming"

  org_prefix    = var.org_prefix
  environment   = var.environment
  resource_type = "rg"
  region_code   = var.region_code
  instance      = var.resource_group_instance
}

module "sample_resource_group" {
  count  = var.deploy_sample_resource_group ? 1 : 0
  source = "./resources"

  rg_name  = module.naming_resource_group.resource_name
  location = var.location
  tags     = local.sample_resource_group_tags
}
