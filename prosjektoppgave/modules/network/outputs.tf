output "subnet_ids" {
  value = {
    AzureFirewallSubnet           = azurerm_subnet.hub_firewall.id
    AzureFirewallManagementSubnet = azurerm_subnet.hub_management.id
    snet-aca                      = azurerm_subnet.spoke_aca.id
  }
}

output "subnet_prefixes" {
  value = {
    snet-aca = local.aca_subnet_prefix
  }
}
