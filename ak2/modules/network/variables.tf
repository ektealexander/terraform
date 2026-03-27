# =============================================================================
# module: network - vnet + subnets
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
  description = "prefix for nsg and related names"
}

variable "vnet_name" {
  type        = string
  description = "virtual network name"
}

variable "address_space" {
  type        = list(string)
  description = "vnet address space"
}

variable "subnet_names" {
  type        = list(string)
  description = "one subnet name per index"
}

variable "subnet_ranges" {
  type        = list(string)
  description = "cidr for each subnet; length must match subnet_names"
}