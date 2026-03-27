# =============================================================================
# module: vm scale set (linux vmss + lb backend)
# changes: root terraform.tfvars and this file
# =============================================================================

resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                = "${var.name_prefix}-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  instances           = var.capacity
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  upgrade_mode        = "Manual"
  overprovision       = false
  health_probe_id     = var.health_probe_id

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  custom_data = var.custom_data

  network_interface {
    name    = "primary"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id

      load_balancer_backend_address_pool_ids = [var.backend_address_pool_id]
    }
  }

  scale_in {
    rule = "Default"
  }
}