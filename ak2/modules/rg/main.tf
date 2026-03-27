# =============================================================================
# module: resource group
# changes: root terraform.tfvars (rg name + location)
# =============================================================================

resource "azurerm_resource_group" "ak2" {
  name     = var.rg_name
  location = var.location
}