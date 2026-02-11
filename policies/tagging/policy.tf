locals {
  policy_key             = basename(path.module)
  policy_definition_file = "${path.module}/definition.json"
}

output "policy_key" {
  value = local.policy_key
}

output "policy_definition_file" {
  value = local.policy_definition_file
}
