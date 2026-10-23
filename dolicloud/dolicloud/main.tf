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

module "networking" {
  source = "./modules/networking"

  project_name        = var.project_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  vnet_cidr          = var.vnet_cidr
  subnet_cidr        = var.subnet_cidr
  http_allowed_cidrs = var.http_allowed_cidrs
  ssh_allowed_cidrs  = var.ssh_allowed_cidrs
}

module "compute" {
  source = "./modules/compute"

  project_name        = var.project_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  subnet_id           = module.networking.subnet_id
  vm_size             = var.vm_size
  os_disk_size        = var.os_disk_size
  admin_username      = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  dolibarr_version     = var.dolibarr_version
  dolibarr_admin_login = var.dolibarr_admin_login
  php_timezone         = var.php_timezone
}
