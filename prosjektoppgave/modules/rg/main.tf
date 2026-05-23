# =============================================================================
# module: resource group
# changes: root terraform.tfvars (rg_name, location)
# =============================================================================

resource "azurerm_resource_group" "prosjektoppgave" {
  name     = var.rg_name
  location = var.location
}
