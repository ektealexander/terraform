# =============================================================================
# module: network - hub/spoke vnets, peering, aca subnet, nsg
# changes: root terraform.tfvars (hub_address_space, spoke_address_space)
# =============================================================================

locals {
  hub_subnets = {
    AzureFirewallSubnet           = cidrsubnet(var.hub_address_space[0], 2, 0) # /26
    AzureFirewallManagementSubnet = cidrsubnet(var.hub_address_space[0], 2, 1) # /26 (required for Basic SKU firewall)
  }
  aca_subnet_prefix = cidrsubnet(var.spoke_address_space[0], 7, 2)
}

resource "azurerm_virtual_network" "hub" {
  name                = "${var.name_prefix}-vnet-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.hub_address_space
}

resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [local.hub_subnets.AzureFirewallSubnet]

  depends_on = [azurerm_virtual_network.hub]
}

resource "azurerm_subnet" "hub_management" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [local.hub_subnets.AzureFirewallManagementSubnet]

  depends_on = [azurerm_virtual_network.hub]
}

resource "azurerm_virtual_network" "spoke" {
  name                = "${var.name_prefix}-vnet-spoke"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.spoke_address_space
}

resource "azurerm_subnet" "spoke_aca" {
  name                 = "snet-aca"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [local.aca_subnet_prefix]

  delegation {
    name = "aca-environment"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "${var.name_prefix}-peer-hub-spoke"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [azurerm_virtual_network.hub, azurerm_virtual_network.spoke]
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "${var.name_prefix}-peer-spoke-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [azurerm_virtual_network.hub, azurerm_virtual_network.spoke]
}

resource "azurerm_network_security_group" "aca" {
  name                = "${var.name_prefix}-nsg-aca"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "deny-ssh-internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-rdp-internet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https-out"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = local.aca_subnet_prefix
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "aca" {
  subnet_id                 = azurerm_subnet.spoke_aca.id
  network_security_group_id = azurerm_network_security_group.aca.id
}
