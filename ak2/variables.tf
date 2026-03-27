# =============================================================================
# root variables: set values in terraform.tfvars
# changes: terraform.tfvars and this file
# default: if not set collected from terraform.tfvars
# sensitive: prevent sensitive values from being printed in the plan
# =============================================================================

variable "subscription_id" {
  type        = string
  description = "azure subscription id used by azurerm provider"
  sensitive   = true
}

# resource group (module.resource_group)
variable "rg_name" {
  type        = string
  description = "name of the resource group"
}

variable "location" {
  type        = string
  description = "azure region"
}

# policies (module.policies)
variable "allowed_policy_locations" {
  type        = list(string)
  description = "locations enforced by the allowed locations policy"
  default     = null
}

variable "allowed_policy_vm_skus" {
  type        = list(string)
  description = "vm skus allowed by policy"
  default     = null
}

# network (module.network)
variable "vnet_name" {
  type        = string
  description = "virtual network name"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "address space for the vnet"
}

variable "subnet_names" {
  type        = list(string)
  description = "subnet names"
}

variable "subnet_ranges" {
  type        = list(string)
  description = "cidr for each subnet"
}

# shared naming (network/lb/vmss)
variable "name_prefix" {
  type        = string
  description = "prefix for resource names"
}

# vmss (module.vmss)
variable "vmss_capacity" {
  type        = number
  description = "number of vmss"
}

variable "vmss_sku" {
  type        = string
  description = "vm size for vmss"
}

variable "admin_username" {
  type        = string
  description = "local admin username on linux"
}

variable "admin_password" {
  type        = string
  description = "admin password for linux vmss"
  sensitive   = true
}