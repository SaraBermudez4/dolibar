output "dolibarr_url" {
  description = "URL del ERP (la instalacion automatica tarda unos minutos la primera vez)"
  value       = module.compute.app_url
}

output "mysql_fqdn" {
  description = "Host privado de MySQL (solo resuelve dentro de la VNet)"
  value       = module.database.fqdn
}

output "resource_group_name" {
  description = "Grupo de recursos que contiene todo el despliegue"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID de la red virtual"
  value       = module.networking.vnet_id
}
