# =============================================================================
# root outputs: values after terraform apply
# changes: rename or extend outputs here
# =============================================================================

output "resource_group_name" {
  description = "deployed rg name"
  value       = module.resource_group.rg_name
}

output "load_balancer_public_ip" {
  description = "public ip of the standard lb"
  value       = module.load_balancer.public_ip_address
}