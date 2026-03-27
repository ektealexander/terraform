# =============================================================================
# module: resource group
# changes: root terraform.tfvars
# =============================================================================

variable "rg_name" {
  type        = string
  description = "resource group name"
}

variable "location" {
  type        = string
  description = "azure region"
}