variable "subscription_id" {
  description = "Azure subscription ID (az account show --query id -o tsv)"
  type        = string
}

variable "location" {
  description = "Azure region (Azure for Students puede restringir algunas regiones)"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Prefijo para los nombres de los recursos"
  type        = string
  default     = "dolicloud"
}

# ---------------------------------------------------------------- Red
variable "vnet_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "apps_subnet_cidr" {
  description = "Subred del Container Apps Environment (minimo /23)"
  type        = string
  default     = "10.1.0.0/23"
}

variable "mysql_subnet_cidr" {
  description = "Subred delegada a MySQL Flexible Server"
  type        = string
  default     = "10.1.2.0/24"
}

# ---------------------------------------------------------------- MySQL
variable "mysql_sku" {
  description = "B_Standard_B1ms entra en los servicios gratis de Azure for Students"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "db_name" {
  type    = string
  default = "dolibarrdb"
}

variable "db_username" {
  description = "Usuario administrador de MySQL (no puede ser admin, root, azure_superuser...)"
  type        = string
  default     = "dolibarr"
}

variable "db_password" {
  description = "Clave de MySQL: 12+ caracteres, mayusculas, minusculas y numeros"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 12 && !can(regex("['\"\\\\$`]", var.db_password))
    error_message = "db_password debe tener 12+ caracteres y no contener comillas, backslash, backtick ni $."
  }
}

# ---------------------------------------------------------------- Dolibarr
variable "image" {
  description = "Imagen del contenedor. cache-redis la reemplaza por la suya (ACR) en la integracion"
  type        = string
  default     = "docker.io/dolibarr/dolibarr:22.0.5"
}

variable "dolibarr_admin_login" {
  type    = string
  default = "admin"
}

variable "dolibarr_admin_password" {
  description = "Clave del usuario administrador de Dolibarr"
  type        = string
  sensitive   = true
}

variable "php_timezone" {
  type    = string
  default = "America/Bogota"
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  description = "Dejar en 1 hasta tener Redis: sin sesiones compartidas, 2 replicas cierran la sesion"
  type        = number
  default     = 1
}

# ---------------------------------------------------------------- Contrato con cache-redis (Redis)
# Vacias por defecto: Dolibarr funciona sin Redis. En la integracion se llenan
# con los outputs de cache-redis.
variable "redis_host" {
  type    = string
  default = null
}

variable "redis_port" {
  type    = number
  default = null
}

variable "redis_password" {
  type      = string
  default   = null
  sensitive = true
}
