# =============================================================================
# module: cost
# changes: root terraform.tfvars
# =============================================================================

variable "resource_group_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "cost_budget_amount" {
  type = number
}

variable "alert_email" {
  type    = string
  default = ""
}
