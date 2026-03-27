# =============================================================================
# module: network (outputs)
# changes: none
# =============================================================================

output "subnet_ids" {
  description = "map subnet name to subnet id"
  value       = local.subnet_name_to_id
}