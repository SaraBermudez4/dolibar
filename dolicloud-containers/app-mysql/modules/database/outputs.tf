output "fqdn" {
  description = "Host privado de MySQL"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "db_name" {
  description = "Nombre de la base, disponible cuando el servidor ya acepta conexiones sin TLS"
  value       = azurerm_mysql_flexible_database.dolibarr.name

  depends_on = [azurerm_mysql_flexible_server_configuration.no_tls]
}
