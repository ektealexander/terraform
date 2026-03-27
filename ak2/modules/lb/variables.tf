# =============================================================================
# module: load balancer - lb + pip
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
  description = "prefix for lb and pip names"
}