terraform {
  backend "azurerm" {
    resource_group_name  = "__TFSTATE_RESOURCE_GROUP__"
    storage_account_name = "__TFSTATE_STORAGE_ACCOUNT__"
    container_name       = "__TFSTATE_CONTAINER__"
    key                  = "__TFSTATE_KEY__"
  }
}
