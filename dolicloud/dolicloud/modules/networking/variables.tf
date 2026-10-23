variable "project_name" {
  description = "Name of the project, used as prefix for resource names"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that holds the resources"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "http_allowed_cidrs" {
  description = "CIDR blocks allowed to reach Dolibarr over HTTP"
  type        = list(string)
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to open an SSH session on the VM"
  type        = list(string)
}
