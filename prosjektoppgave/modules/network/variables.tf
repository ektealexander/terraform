# =============================================================================
# module: network
# changes: root terraform.tfvars
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

variable "hub_address_space" {
  type        = list(string)
  description = "hub vnet cidr blocks"
}

variable "spoke_address_space" {
  type        = list(string)
  description = "spoke vnet cidr blocks"
}
