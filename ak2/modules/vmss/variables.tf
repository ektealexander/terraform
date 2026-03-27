# =============================================================================
# module: vm scale set (inputs)
# changes: root terraform.tfvars
# =============================================================================

variable "name_prefix" {
  type        = string
  description = "prefix for the scale set name"
}

variable "resource_group_name" {
  type        = string
  description = "resource group name"
}

variable "location" {
  type        = string
  description = "azure region"
}

variable "subnet_id" {
  type        = string
  description = "subnet id for vmss instances (private; traffic via lb)"
}

variable "capacity" {
  type        = number
  description = "instance count (>= 2 for ha)"
}

variable "sku" {
  type        = string
  description = "vm size sku"
}

variable "admin_username" {
  type        = string
  description = "linux admin user"
}

variable "admin_password" {
  type        = string
  description = "admin password (azure complexity rules: length + mixed character classes)"
  sensitive   = true
}

variable "backend_address_pool_id" {
  type        = string
  description = "standard lb backend pool id"
}

variable "health_probe_id" {
  type        = string
  description = "lb probe id required by standard sku vmss"
}

variable "custom_data" {
  type        = string
  description = "base64-encoded cloud-init"
}