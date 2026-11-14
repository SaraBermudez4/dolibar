resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Subred de los contenedores. Azure exige delegarla a Container Apps.
resource "azurerm_subnet" "apps" {
  name                 = "${var.project_name}-apps-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.apps_subnet_cidr]

  delegation {
    name = "container-apps"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Subred exclusiva de MySQL Flexible Server.
resource "azurerm_subnet" "mysql" {
  name                 = "${var.project_name}-mysql-subnet"
  resource_group_name  = var.resource_group_name
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
