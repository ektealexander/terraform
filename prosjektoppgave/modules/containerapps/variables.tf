# =============================================================================
# module: containerapps
# changes: root terraform.tfvars
# =============================================================================

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "subnet_id_aca" {
  type        = string
  description = "snet-aca (Microsoft.App/environments delegation)"
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "django_container_image" {
  type        = string
  description = "Django image repo:tag on this module's ACR (e.g. ecommerce:latest)"
  default     = "ecommerce:latest"
}

variable "allowed_hosts" {
  type        = string
  description = "Django ALLOWED_HOSTS (comma-separated)"
}

variable "app_target_port" {
  type        = number
  description = "ACA ingress target port (8000 for Django/gunicorn)"
  default     = 8000
}

variable "mysql_database_name" {
  type    = string
  default = "tverr"
}

variable "mysql_admin_username" {
  type        = string
  description = "App DB user (bedrift in ecom3.sql)"
  default     = "bedrift"
}

variable "mysql_app_password" {
  type        = string
  sensitive   = true
  description = "Password for mysql_admin_username (Passord123 in upstream dump)"
}

variable "mysql_container_image" {
  type        = string
  description = "MySQL image repo:tag on ACR (ecommerce-mysql with ecom3.sql)"
  default     = "ecommerce-mysql:latest"
}
