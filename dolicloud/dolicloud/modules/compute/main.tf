resource "azurerm_public_ip" "dolibarr" {
  name                = "${var.project_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "dolibarr" {
  name                = "${var.project_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dolibarr.id
  }
}

resource "azurerm_linux_virtual_machine" "dolibarr" {
  name                  = "${var.project_name}-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.dolibarr.id]
  tags                  = var.tags

  # Solo autenticacion por llave: la VM no acepta contrasenas por SSH.
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  # cloud-init ejecuta este script la primera vez que arranca la VM.
  custom_data = base64encode(templatefile("${path.module}/templates/cloud-init.sh.tpl", {
    db_name              = var.db_name
    db_username          = var.db_username
    db_password          = var.db_password
    dolibarr_version     = var.dolibarr_version
    dolibarr_admin_login = var.dolibarr_admin_login
    php_timezone         = var.php_timezone
  }))

  os_disk {
    name                 = "${var.project_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.os_disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # Habilita la consola serie para diagnosticar el arranque desde el portal.
  boot_diagnostics {}
}
