# =============================================================================
# module: routing
# changes: wired from root main.tf (after module.firewall)
# =============================================================================

variable "resource_group_name" {
  type        = string
  description = "resource group name"
}

variable "location" {
  type        = string
  description = "azure region"
}

variable "name_prefix" {
  type        = string
  description = "prefix for resource names"
}

variable "subnet_id_aca" {
  type        = string
  description = "module.network.subnet_ids[\"snet-aca\"]"
}

variable "firewall_private_ip" {
  type        = string
  description = "module.firewall.firewall_private_ip (udr next hop)"
}
