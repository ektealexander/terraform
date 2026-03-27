# =============================================================================
# root module: connects rg, policies, subnets, lb and vmss
# changes: terraform.tfvars and variables.tf
# =============================================================================

locals {
  # policy "allowed locations": defaults to single region = var.location if unset
  allowed_locations = coalesce(var.allowed_policy_locations, [var.location])
  # policy "allowed virtual machine size skus": defaults to deployed vmss sku if unset
  allowed_vm_skus = coalesce(var.allowed_policy_vm_skus, [var.vmss_sku])
}

module "resource_group" {
  source = "./modules/rg"

  rg_name  = var.rg_name
  location = var.location
}

module "policies" {
  source = "./modules/policies"

  resource_group_id = module.resource_group.rg_id
  subscription_id   = var.subscription_id
  allowed_locations = local.allowed_locations
  allowed_vm_skus   = local.allowed_vm_skus

  depends_on = [module.resource_group]
}

module "network" {
  source = "./modules/network"

  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location
  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space
  subnet_names        = var.subnet_names
  subnet_ranges       = var.subnet_ranges
  name_prefix         = var.name_prefix

  depends_on = [module.resource_group]
}

module "load_balancer" {
  source = "./modules/lb"

  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location
  name_prefix         = var.name_prefix

  depends_on = [module.resource_group]
}

module "vmss" {
  source = "./modules/vmss"

  name_prefix         = var.name_prefix
  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location

  subnet_id = module.network.subnet_ids[var.subnet_names[0]]

  capacity = var.vmss_capacity
  sku      = var.vmss_sku

  admin_username = var.admin_username
  admin_password = var.admin_password

  backend_address_pool_id = module.load_balancer.backend_address_pool_id
  health_probe_id         = module.load_balancer.health_probe_id

  # cloud-init template: edit cloud-init/web.yaml to change packages or site content
  custom_data = filebase64("${path.module}/cloud-init/web.yaml")

  depends_on = [module.network, module.load_balancer]
}