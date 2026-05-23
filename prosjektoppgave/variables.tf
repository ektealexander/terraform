# =============================================================================
# root variables: set values in terraform.tfvars
# changes: terraform.tfvars and this file
# default: if not set, collected from terraform.tfvars
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
  description = "azure region (e.g. norwayeast)"
}

# shared naming (network, firewall, monitor, cost, containerapps)
variable "name_prefix" {
  type        = string
  description = "prefix for resource names"
}

# network (module.network)
variable "hub_address_space" {
  type        = list(string)
  description = "hub vnet cidr blocks"
}

variable "spoke_address_space" {
  type        = list(string)
  description = "spoke vnet cidr blocks (aca subnet is carved from here)"
}

# firewall (module.firewall)
variable "firewall_sku" {
  type        = string
  description = "azure firewall sku tier (basic or standard)"
}

variable "allow_app_https_out" {
  type        = bool
  description = "allow https from aca subnet to internet via firewall"
}

# monitor (module.monitor)
variable "law_retention_days" {
  type        = number
  description = "log analytics retention in days"
}

variable "alert_email" {
  type        = string
  description = "email for monitor alerts and cost budget (empty skips email resources)"
}

# cost (module.cost)
variable "cost_budget_amount" {
  type        = number
  description = "monthly spend limit for the resource group"
}

# containerapps (module.containerapps)
variable "django_allowed_hosts" {
  type        = string
  description = "django allowed_hosts (comma-separated; include .azurecontainerapps.io)"
}

variable "django_container_image" {
  type        = string
  description = "django image repo:tag on terraform-created acr"
}

variable "app_target_port" {
  type        = number
  description = "aca ingress target port (8000 for django/gunicorn)"
}

variable "mysql_container_image" {
  type        = string
  description = "mysql image repo:tag on acr"
}

variable "mysql_database_name" {
  type        = string
  description = "database name (tverr in upstream ecom3.sql)"
}

variable "mysql_admin_username" {
  type        = string
  description = "app db user (bedrift in upstream ecom3.sql)"
}

variable "mysql_app_password" {
  type        = string
  description = "password for mysql_admin_username; must match ecom3.sql if using sample dump"
  sensitive   = true
}
