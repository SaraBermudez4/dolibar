# Base de datos relacional gestionada: Azure Database for MySQL Flexible Server.
# Sin IP publica: solo se alcanza desde la VNet, por DNS privado.
resource "azurerm_private_dns_zone" "mysql" {
  name                = "${var.project_name}.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "${var.project_name}-mysql-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

resource "azurerm_mysql_flexible_server" "main" {
  name                = "${var.project_name}-mysql-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  administrator_login    = var.db_username
  administrator_password = var.db_password

  sku_name = var.sku_name
  version  = "8.0.21"

  storage {
    size_gb = 20
  }

  backup_retention_days = 7

  delegated_subnet_id = var.subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.mysql.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql]

  lifecycle {
    # Azure asigna la zona si no se indica; ignorarla evita diffs en cada plan.
    ignore_changes = [zone]
  }
}

resource "azurerm_mysql_flexible_database" "dolibarr" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# El trafico viaja solo por la red privada; se desactiva el TLS obligatorio
# para que el driver mysqli de Dolibarr conecte sin certificados.
resource "azurerm_mysql_flexible_server_configuration" "no_tls" {
  name                = "require_secure_transport"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = "OFF"
}
