# =============================================================================
# provider: terraform + azurerm
# changes: variables.tf and terraform.tfvars
# =============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.65.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}