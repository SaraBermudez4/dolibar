variable "subscription_id" {
  description = "Azure subscription ID (az account show --query id -o tsv)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Name of the project, used as prefix for resource names"
  type        = string
  default     = "dolicloud"
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "http_allowed_cidrs" {
  description = "CIDR blocks allowed to reach Dolibarr over HTTP"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to open an SSH session on the VM"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1ms"
}

variable "os_disk_size" {
  description = "Size in GB of the OS disk"
  type        = number
  default     = 30
}

variable "admin_username" {
  description = "Linux administrator username on the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used to reach the VM"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "db_name" {
  description = "Name of the Dolibarr database"
  type        = string
  default     = "dolibarrdb"
}

variable "db_username" {
  description = "Username for the Dolibarr database"
  type        = string
  default     = "dolibarr"
}

variable "db_password" {
  description = "Password for the Dolibarr database"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 12 && !can(regex("['\"\\\\$`]", var.db_password))
    error_message = "db_password must be at least 12 characters and must not contain quotes, backslashes, backticks or $."
  }
}

variable "dolibarr_version" {
  description = "Dolibarr release tag to deploy (GitHub tag, e.g. 22.0.5)"
  type        = string
  default     = "22.0.5"
}

variable "dolibarr_admin_login" {
  description = "Login of the Dolibarr administrator user created by the wizard"
  type        = string
  default     = "admin"
}

variable "php_timezone" {
  description = "Timezone used by PHP on the VM"
  type        = string
  default     = "America/Bogota"
}
