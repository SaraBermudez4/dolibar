output "dolibarr_url" {
  description = "URL to access the Dolibarr ERP"
  value       = module.compute.dolibarr_url
}

output "dolibarr_install_url" {
  description = "URL of the Dolibarr installation wizard (run once)"
  value       = module.compute.dolibarr_install_url
}

output "public_ip" {
  description = "Public IP of the Dolibarr VM"
  value       = module.compute.public_ip
}

output "ssh_command" {
  description = "Command to open a shell on the VM"
  value       = module.compute.ssh_command
}

output "resource_group_name" {
  description = "Resource group that holds the whole deployment"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID of the virtual network created"
  value       = module.networking.vnet_id
}
