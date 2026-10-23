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

variable "subnet_id" {
  description = "ID of the subnet where the VM is placed"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
}

variable "os_disk_size" {
  description = "Size in GB of the OS disk"
  type        = number
}

variable "admin_username" {
  description = "Linux administrator username on the VM"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used to reach the VM"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "dolibarr_version" {
  description = "Dolibarr release tag to deploy"
  type        = string
}

variable "dolibarr_admin_login" {
  description = "Login of the Dolibarr administrator user"
  type        = string
}

variable "php_timezone" {
  description = "Timezone used by PHP on the VM"
  type        = string
}
