subscription_id = ""
org_prefix      = "lekhika"
environment     = "dev"
region_code     = "eus2"
location        = "eastus2"

policy_scope_type          = "resource_group"
management_group_id        = ""
policy_assignment_location = "eastus"

create_governance_resource_group = true
governance_resource_group_name   = "lekhika-dev-rg-eus2"

deploy_free_app_service   = true
app_service_plan_sku_name = "B1"
app_service_name_prefix   = "lekhika-dev-webapp"

mandatory_tags = [
  "Environment",
  "Owner"
]

default_tags = {
  Environment = "dev"
  Owner       = "platform-team"
  CostCenter  = "IT-DEV-001"
}

policy_assignment_parameters = {
  naming = {
    orgPrefix   = "lekhika"
    environment = "dev"
    regionCode  = "eus2"
    effect      = "Deny"
  }
  tagging = {
    effect = "Deny"
  }
}
