output "container_app_fqdn" {
  description = "Public HTTPS FQDN for ingress"
  value       = azurerm_container_app.ecommerce.ingress[0].fqdn
}

output "container_app_url" {
  value = "https://${azurerm_container_app.ecommerce.ingress[0].fqdn}"
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}
