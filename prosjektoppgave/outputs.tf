# =============================================================================
# root outputs: values after terraform apply
# changes: rename or extend outputs here
# =============================================================================

output "resource_group_name" {
  description = "deployed rg name"
  value       = module.resource_group.rg_name
}

output "container_app_url" {
  description = "https url for the ecommerce container app (open in browser)"
  value       = module.containerapps.container_app_url
}

output "container_app_fqdn" {
  description = "fqdn to add in terraform.tfvars django_allowed_hosts"
  value       = module.containerapps.container_app_fqdn
}

output "acr_login_server" {
  description = "acr login server (used by scripts/build-acr.ps1)"
  value       = module.containerapps.acr_login_server
}

output "firewall_private_ip" {
  description = "azure firewall private ip (udr next hop in module.routing)"
  value       = module.firewall.firewall_private_ip
}
