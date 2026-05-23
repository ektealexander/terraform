# =============================================================================
# module: routing - spoke default route via azure firewall
# changes: root main.tf (firewall_private_ip from module.firewall)
# =============================================================================

resource "azurerm_route_table" "spoke_udr" {
  name                = "${var.name_prefix}-rt-spoke-azfw"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "default-via-azure-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "spoke_aca" {
  subnet_id      = var.subnet_id_aca
  route_table_id = azurerm_route_table.spoke_udr.id
}
