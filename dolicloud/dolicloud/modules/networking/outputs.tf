output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "ID of the subnet where the VM is placed"
  value       = azurerm_subnet.public.id
}

output "nsg_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.web.id
}
