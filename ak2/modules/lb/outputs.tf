# =============================================================================
# module: load balancer - lb + pip
# changes: none
# =============================================================================

output "public_ip_address" {
  description = "public ipv4 address of the load balancer"
  value       = azurerm_public_ip.lb.ip_address
}

output "backend_address_pool_id" {
  description = "backend pool id for vmss ip_configuration"
  value       = azurerm_lb_backend_address_pool.vmss.id
}

output "health_probe_id" {
  description = "http probe id for the vmss health_probe_id"
  value       = azurerm_lb_probe.http.id
}