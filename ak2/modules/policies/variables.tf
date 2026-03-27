# =============================================================================
# module: policies (inputs)
# changes: root terraform.tfvars (allowed_policy_locations) and module interface here
# =============================================================================

variable "resource_group_id" {
  type        = string
  description = "target resource group for policy assignments"
}

variable "subscription_id" {
  type        = string
  description = "target subscription id for subscription-scope policy assignments"
}

variable "allowed_locations" {
  type        = list(string)
  description = "locations allowed by the allowed locations policy"
}

variable "allowed_vm_skus" {
  type        = list(string)
  description = "allowed vm sku list used by the allowed vm skus policy"
}
