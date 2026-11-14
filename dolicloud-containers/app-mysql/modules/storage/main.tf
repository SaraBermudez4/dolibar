# Azure Files: carpeta /var/www/documents de Dolibarr (adjuntos, install.lock).
# Persiste aunque el contenedor se reinicie y la comparten todas las replicas.
resource "azurerm_storage_account" "docs" {
  # 3-24 caracteres, solo minusculas y numeros, unico global.
  name                     = "${replace(var.project_name, "-", "")}docs${var.name_suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_storage_share" "documents" {
  name               = "documents"
  storage_account_id = azurerm_storage_account.docs.id
  quota              = 5
}
