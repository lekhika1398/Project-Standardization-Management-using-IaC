data "azurerm_subscription" "current" {}

locals {
  mandatory_tags_map = {
    for tag_name in var.mandatory_tags :
    tag_name => lookup(var.default_tags, tag_name, "required")
  }

  governance_tags = merge(local.mandatory_tags_map, var.default_tags, {
    ManagedBy = "Terraform"
  })

  subscription_scope_id     = var.subscription_id != "" ? "/subscriptions/${var.subscription_id}" : data.azurerm_subscription.current.id
  management_group_scope_id = var.management_group_id != "" ? "/providers/Microsoft.Management/managementGroups/${var.management_group_id}" : null
}

module "deployment_resource_group" {
  source = "./modules/resource-group"

  create_resource_group = var.create_deployment_resource_group
  rg_name               = var.deployment_resource_group_name
  location              = var.location
  tags                  = local.governance_tags
}

module "governance_app_service" {
  source = "./modules/app-service"

  deploy                  = var.deploy_free_app_service
  service_plan_sku_name   = var.app_service_plan_sku_name
  resource_group_name     = module.deployment_resource_group.name
  location                = module.deployment_resource_group.location
  tags                    = local.governance_tags
  app_service_name_prefix = var.app_service_name_prefix
  environment             = var.environment
  subscription_id         = data.azurerm_subscription.current.subscription_id
}

module "policy_engine" {
  source = "./modules/policy-engine"

  org_prefix                   = var.org_prefix
  environment                  = var.environment
  region_code                  = var.region_code
  policy_scope_type            = var.policy_scope_type
  subscription_scope_id        = local.subscription_scope_id
  resource_group_scope_id      = module.deployment_resource_group.id
  management_group_scope_id    = local.management_group_scope_id
  policy_assignment_location   = var.policy_assignment_location
  policy_assignment_parameters = var.policy_assignment_parameters
  policies_path                = "${path.module}/policies"
}
