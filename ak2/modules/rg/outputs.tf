# =============================================================================
# module: resource group outputs
# changes: add outputs here
# =============================================================================

output "rg_name" {
  value       = azurerm_resource_group.ak2.name
  description = "resource group name"
}

output "rg_location" {
  value       = azurerm_resource_group.ak2.location
  description = "resource group location"
}

output "rg_id" {
  value       = azurerm_resource_group.ak2.id
  description = "resource group id"
}