# =============================================================================
# module: monitor
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

variable "log_analytics_retention_days" {
  type        = number
  description = "log analytics retention in days"
}

variable "alert_email" {
  type        = string
  description = "alert email (empty = no email action group on alerts)"
  default     = ""
}
