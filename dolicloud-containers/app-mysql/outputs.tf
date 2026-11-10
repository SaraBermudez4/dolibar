output "dolibarr_url" {
  description = "URL del ERP (la instalacion automatica tarda unos minutos la primera vez)"
  value       = local.app_url
}

output "mysql_fqdn" {
  description = "Host privado de MySQL (solo resuelve dentro de la VNet)"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

# Lo que cache-redis necesita en la integracion para poner Redis en esta VNet.
output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}
