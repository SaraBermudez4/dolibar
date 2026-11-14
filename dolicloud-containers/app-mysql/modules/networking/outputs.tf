output "vnet_id" {
  description = "ID de la red virtual"
  value       = azurerm_virtual_network.main.id
}

output "apps_subnet_id" {
  description = "ID de la subred de Container Apps"
  value       = azurerm_subnet.apps.id
}

output "mysql_subnet_id" {
  description = "ID de la subred de MySQL"
  value       = azurerm_subnet.mysql.id
}
