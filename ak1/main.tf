terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.62.1"
    }
  }
}

#configure microsoft azure provider
provider "azurerm" {
  features {}
  subscription_id = "fedc4ad6-1398-4394-9fdc-fe5b7c031583"
}

#create a resource group
resource "azurerm_resource_group" "terraform" {
  name     = "terraform"
  location = "Norway East"
}