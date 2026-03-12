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

#create a virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
}

#subnet for vm1
resource "azurerm_subnet" "vm1" {
  name                 = "vm1-subnet"
  resource_group_name  = azurerm_resource_group.terraform.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["192.168.1.0/24"]
}

#subnet for vm2
resource "azurerm_subnet" "vm2" {
  name                 = "vm2-subnet"
  resource_group_name  = azurerm_resource_group.terraform.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["192.168.2.0/24"]
}

#public ip for vm1 for ssh
resource "azurerm_public_ip" "vm1" {
  name                = "vm1-public-ip"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#nsg for vm1 for ssh
resource "azurerm_network_security_group" "vm1" {
  name                = "vm1-nsg"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm1" {
  name                = "vm1-nic"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1.id
  }
}

resource "azurerm_network_interface_security_group_association" "vm1_nsg" {
  network_interface_id      = azurerm_network_interface.vm1.id
  network_security_group_id = azurerm_network_security_group.vm1.id
}

#vm2 for ansible
resource "azurerm_network_interface" "vm2" {
  name                = "vm2-nic"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.2.4"
  }
}

resource "azurerm_network_interface_security_group_association" "vm2_nsg" {
  network_interface_id      = azurerm_network_interface.vm2.id
  network_security_group_id = azurerm_network_security_group.ssh_to_vm2.id
}

#nsg for vm2 for ssh
resource "azurerm_network_security_group" "ssh_to_vm2" {
  name                = "vm2-nsg"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name

  security_rule {
    name                       = "AllowSSHFromVM1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "192.168.1.0/24"
    destination_address_prefix = "*"
  }
}


#vm1 for ansible
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.terraform.name
  location            = azurerm_resource_group.terraform.location
  size                = "Standard_F2"
  admin_username      = "alespiadm"
  admin_password      = "Password123"
  network_interface_ids = [
    azurerm_network_interface.vm1.id,
  ]

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

#vm2 for ansible
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm2"
  resource_group_name = azurerm_resource_group.terraform.name
  location            = azurerm_resource_group.terraform.location
  size                = "Standard_F2"
  admin_username      = "alespiadm"
  admin_password      = "Password123"
  network_interface_ids = [
    azurerm_network_interface.vm2.id,
  ]

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# VM1 offentlig IP (for SSH fra PC)
output "vm1_public_ip" {
  value       = azurerm_public_ip.vm1.ip_address
  description = "Offentlig IP for VM1 (SSH: ssh alespiadm@<denne>)"
}