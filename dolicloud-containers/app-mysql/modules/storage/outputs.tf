output "account_name" {
  description = "Nombre de la cuenta de almacenamiento"
  value       = azurerm_storage_account.docs.name
}

output "account_key" {
  description = "Clave de acceso de la cuenta de almacenamiento"
  value       = azurerm_storage_account.docs.primary_access_key
  sensitive   = true
}

output "share_name" {
  description = "Nombre del recurso compartido de Azure Files"
  value       = azurerm_storage_share.documents.name
}
