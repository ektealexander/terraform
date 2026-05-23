# =============================================================================
# module: firewall
# changes: root terraform.tfvars and root main.tf (subnet ids from module.network)
# =============================================================================

variable "resource_group_name" {
  type        = string
  description = "RG name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "name_prefix" {
  type        = string
  description = "Resource name prefix"
}

variable "hub_subnet_id_firewall" {
  type        = string
  description = "module.network.subnet_ids[\"AzureFirewallSubnet\"]"
}

variable "hub_subnet_id_management" {
  type        = string
  description = "module.network.subnet_ids[\"AzureFirewallManagementSubnet\"] (Basic SKU)"
}

variable "firewall_sku" {
  type        = string
  description = "Basic or Standard – set in root locals"
  default     = "Basic"
}

variable "allow_app_outbound_internet" {
  type        = bool
  description = "Create HTTPS * application rule for app subnet (root local allow_app_https_out)"
}

variable "workload_subnet_prefix" {
  type        = string
  description = "snet-aca CIDR for firewall source addresses"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "LAW id for firewall diagnostics"
}
