provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

locals {
  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
  redis_enabled = var.redis_host != null
}

resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.location
  tags     = local.tags
}

# ------------------------------------------------------------------------------
# Red: una VNet con una subred para los contenedores y otra para MySQL.
# cache-redis agrega su propia subred (10.1.3.0/24) en la integracion.
# ------------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_subnet" "apps" {
  name                 = "${var.project_name}-apps-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.apps_subnet_cidr]
}

resource "azurerm_subnet" "mysql" {
  name                 = "${var.project_name}-mysql-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.mysql_subnet_cidr]

  delegation {
    name = "mysql-flexible"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
