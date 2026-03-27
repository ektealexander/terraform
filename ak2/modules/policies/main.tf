# =============================================================================
# module: policies - built-in definitions assigned to rg scope
# changes: root terraform.tfvars and this file (which policies are assigned)
# use policy ID instead of display name to avoid API version issues
# =============================================================================

# built-in policy: limits where rg can be created
data "azurerm_policy_definition" "allowed_locations_rg" {
  name = "e765b5de-1225-4ba3-bd56-1ac6695af988"
}

# built-in policy: restricts vm sizes to an allowed list
data "azurerm_policy_definition" "allowed_vm_skus" {
  name = "cccc23c7-8427-4f53-ad12-b6a63eb452b3"
}

# built-in policy: disallows public ip on nic resources
data "azurerm_policy_definition" "no_public_ip_on_nic" {
  name = "83a86a26-fd1f-447c-b59d-e51f44264114"
}

# assignment: enforces allowed locations for resource groups
resource "azurerm_subscription_policy_assignment" "allowed_locations_rg" {
  name                 = "allowed-locations-rg"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = data.azurerm_policy_definition.allowed_locations_rg.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}

# assignment: enforces allowed vm size skus at rg level
resource "azurerm_resource_group_policy_assignment" "allowed_vm_skus" {
  name                 = "allowed-vm-skus"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.allowed_vm_skus.id

  parameters = jsonencode({
    listOfAllowedSKUs = {
      value = var.allowed_vm_skus
    }
  })
}

# assignment: audits/denies nics with public ips at rg level
resource "azurerm_resource_group_policy_assignment" "no_public_ip_on_nic" {
  name                 = "no-public-ip-on-nic"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.no_public_ip_on_nic.id
}