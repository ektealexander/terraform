# =============================================================================
# root module: connects rg, cost, monitor, network, firewall, routing, containerapps
# changes: terraform.tfvars and variables.tf
# =============================================================================

module "resource_group" {
  source = "./modules/rg"

  rg_name  = var.rg_name
  location = var.location
}

module "cost" {
  source = "./modules/cost"

  resource_group_id  = module.resource_group.rg_id
  name_prefix        = var.name_prefix
  cost_budget_amount = var.cost_budget_amount
  alert_email        = var.alert_email

  depends_on = [module.resource_group]
}

module "monitor" {
  source = "./modules/monitor"

  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location
  name_prefix         = var.name_prefix

  log_analytics_retention_days = var.law_retention_days
  alert_email                  = var.alert_email

  depends_on = [module.resource_group]
}

module "network" {
  source = "./modules/network"

  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location
  name_prefix         = var.name_prefix

  hub_address_space   = var.hub_address_space
  spoke_address_space = var.spoke_address_space

  depends_on = [module.resource_group]
}

module "firewall" {
  source = "./modules/firewall"

  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location
  name_prefix         = var.name_prefix

  hub_subnet_id_firewall   = module.network.subnet_ids["AzureFirewallSubnet"]
  hub_subnet_id_management = module.network.subnet_ids["AzureFirewallManagementSubnet"]

  firewall_sku                = var.firewall_sku
  allow_app_outbound_internet = var.allow_app_https_out
  workload_subnet_prefix      = module.network.subnet_prefixes["snet-aca"]

  log_analytics_workspace_id = module.monitor.log_analytics_workspace_id

  depends_on = [module.network, module.monitor]
}

module "routing" {
  source = "./modules/routing"

  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location
  name_prefix         = var.name_prefix

  subnet_id_aca       = module.network.subnet_ids["snet-aca"]
  firewall_private_ip = module.firewall.firewall_private_ip

  depends_on = [module.firewall]
}

module "containerapps" {
  source = "./modules/containerapps"

  name_prefix         = var.name_prefix
  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location

  subnet_id_aca              = module.network.subnet_ids["snet-aca"]
  log_analytics_workspace_id = module.monitor.log_analytics_workspace_id

  django_container_image = var.django_container_image
  allowed_hosts          = var.django_allowed_hosts
  app_target_port        = var.app_target_port

  mysql_database_name   = var.mysql_database_name
  mysql_admin_username  = var.mysql_admin_username
  mysql_app_password    = var.mysql_app_password
  mysql_container_image = var.mysql_container_image

  # app images: scripts/setup-ecommerce.ps1 then scripts/build-acr.ps1 (after apply)
  depends_on = [module.network, module.monitor, module.firewall, module.routing]
}
