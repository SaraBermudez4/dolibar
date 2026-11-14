provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

locals {
  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

# Todo el proyecto vive dentro de un unico grupo de recursos:
# borrarlo elimina la infraestructura completa.
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.location
  tags     = local.tags
}

# Los nombres de MySQL y de la cuenta de almacenamiento son globales en Azure:
# el sufijo evita choques con otros grupos.
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "networking" {
  source = "./modules/networking"

  project_name        = var.project_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  vnet_cidr         = var.vnet_cidr
  apps_subnet_cidr  = var.apps_subnet_cidr
  mysql_subnet_cidr = var.mysql_subnet_cidr
}

module "database" {
  source = "./modules/database"

  project_name        = var.project_name
  name_suffix         = random_string.suffix.result
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  vnet_id   = module.networking.vnet_id
  subnet_id = module.networking.mysql_subnet_id

  sku_name    = var.mysql_sku
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

module "storage" {
  source = "./modules/storage"

  project_name        = var.project_name
  name_suffix         = random_string.suffix.result
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

module "compute" {
  source = "./modules/compute"

  project_name        = var.project_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  subnet_id = module.networking.apps_subnet_id

  storage_account_name = module.storage.account_name
  storage_account_key  = module.storage.account_key
  storage_share_name   = module.storage.share_name

  db_host     = module.database.fqdn
  db_name     = module.database.db_name
  db_username = var.db_username
  db_password = var.db_password

  image                   = var.image
  dolibarr_admin_login    = var.dolibarr_admin_login
  dolibarr_admin_password = var.dolibarr_admin_password
  php_timezone            = var.php_timezone
  min_replicas            = var.min_replicas
  max_replicas            = var.max_replicas

  redis_host     = var.redis_host
  redis_port     = var.redis_port
  redis_password = var.redis_password
}
