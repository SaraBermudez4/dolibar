output "dolibarr_url" {
  description = "URL to access the Dolibarr ERP"
  value       = "http://${azurerm_public_ip.dolibarr.ip_address}"
}

output "dolibarr_install_url" {
  description = "URL of the Dolibarr installation wizard (run once)"
  value       = "http://${azurerm_public_ip.dolibarr.ip_address}/install/"
}

output "public_ip" {
  description = "Public IP of the VM"
  value       = azurerm_public_ip.dolibarr.ip_address
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.dolibarr.id
}

output "ssh_command" {
  description = "Command to open a shell on the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.dolibarr.ip_address}"
}
