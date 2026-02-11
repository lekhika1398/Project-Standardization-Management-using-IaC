# Required
subscription_id = ""
org_prefix      = "lekhika"
environment     = "dev"
region_code     = "eus"
location        = "eastus"

# Optional
policy_scope_type          = "resource_group"
management_group_id        = ""
policy_assignment_location = "eastus"

# Optional
deployment_resource_group_name   = "lekhika-dev-rg-eus2"

# Optional
deploy_app_service       = true
app_service_plan_sku_name = "B1"
app_service_name_prefix   = "lekhika-dev-webapp"

# Optional
mandatory_tags = [
  "Environment",
  "Owner"
]

# Optional
default_tags = {
  Environment = "dev"
  Owner       = "platform-team"
  CostCenter  = "IT-DEV-001"
}

# Optional
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
