# =============================================================================
# module: firewall - azure firewall in hub (policy app + network rules)
# changes: root terraform.tfvars (firewall_sku, allow_app_https_out)
# rule priority 300: optional https out; 400: acr/docker hub/dns paas
# =============================================================================

resource "azurerm_public_ip" "firewall" {
  name                = "${var.name_prefix}-pip-azfw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "firewall_management" {
  count = var.firewall_sku == "Basic" ? 1 : 0

  name                = "${var.name_prefix}-pip-azfw-mgmt"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "main" {
  name                = "${var.name_prefix}-fwpolicy"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.firewall_sku

  dynamic "dns" {
    for_each = var.firewall_sku != "Basic" ? [1] : []
    content {
      proxy_enabled = true
      servers       = ["168.63.129.16"]
    }
  }

  threat_intelligence_mode = "Alert"
}

resource "azurerm_firewall_policy_rule_collection_group" "app_rules" {
  count = var.allow_app_outbound_internet ? 1 : 0

  name               = "${var.name_prefix}-app-rules"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 300

  application_rule_collection {
    name     = "allow-workload-https-out"
    priority = 100
    action   = "Allow"

    rule {
      name             = "https-internet"
      source_addresses = [var.workload_subnet_prefix]
      protocols {
        type = "Https"
        port = 443
      }
      destination_fqdns = ["*"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "paas_rules" {
  name               = "${var.name_prefix}-paas-rules"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 400

  application_rule_collection {
    name     = "allow-azure-paas"
    priority = 100
    action   = "Allow"

    rule {
      name             = "acr-management-paas"
      source_addresses = [var.workload_subnet_prefix]
      protocols {
        type = "Https"
        port = 443
      }
      destination_fqdns = [
        "management.azure.com",
        "*.azurecr.io",
        "mcr.microsoft.com",
        "*.mcr.microsoft.com",
        "registry-1.docker.io",
        "auth.docker.io",
        "*.blob.core.windows.net",
      ]
    }
  }

  network_rule_collection {
    name     = "allow-azure-dns"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "azure-dns"
      protocols             = ["UDP", "TCP"]
      source_addresses      = [var.workload_subnet_prefix]
      destination_addresses = ["168.63.129.16"]
      destination_ports     = ["53"]
    }
  }
}

resource "azurerm_firewall" "main" {
  name                = "${var.name_prefix}-azfw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku
  firewall_policy_id  = azurerm_firewall_policy.main.id
  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.hub_subnet_id_firewall
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  dynamic "management_ip_configuration" {
    for_each = var.firewall_sku == "Basic" ? [1] : []
    content {
      name                 = "management"
      subnet_id            = var.hub_subnet_id_management
      public_ip_address_id = azurerm_public_ip.firewall_management[0].id
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "${var.name_prefix}-diag-azfw"
  target_resource_id         = azurerm_firewall.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
