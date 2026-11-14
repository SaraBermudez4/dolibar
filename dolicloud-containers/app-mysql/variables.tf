variable "subscription_id" {
  description = "Azure subscription ID (az account show --query id -o tsv)"
  type        = string
}

variable "location" {
  description = "Region de Azure (Azure for Students puede restringir algunas regiones)"
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
  description = "Rango de la red virtual"
  type        = string
  default     = "10.1.0.0/16"
}

variable "apps_subnet_cidr" {
  description = "Subred del Container Apps Environment"
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
  description = "Tamano del servidor MySQL"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "db_name" {
  description = "Nombre de la base de datos de Dolibarr"
  type        = string
  default     = "dolibarrdb"
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
  description = "Imagen del contenedor; en la integracion se usa la imagen con Redis del ACR"
  type        = string
  default     = "docker.io/dolibarr/dolibarr:22.0.5"
}

variable "dolibarr_admin_login" {
  description = "Usuario administrador de Dolibarr"
  type        = string
  default     = "admin"
}

variable "dolibarr_admin_password" {
  description = "Clave del usuario administrador de Dolibarr"
  type        = string
  sensitive   = true
}

variable "php_timezone" {
  description = "Zona horaria de PHP"
  type        = string
  default     = "America/Bogota"
}

variable "min_replicas" {
  description = "Replicas minimas del contenedor"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Replicas maximas; sin sesiones compartidas en Redis debe quedar en 1"
  type        = number
  default     = 1
}

# ---------------------------------------------------------------- Redis
# Vacias por defecto: Dolibarr funciona sin Redis. En la integracion se llenan
# con las salidas del proyecto de Redis.
variable "redis_host" {
  description = "Host de Azure Managed Redis"
  type        = string
  default     = null
}

variable "redis_port" {
  description = "Puerto de Azure Managed Redis"
  type        = number
  default     = null
}

variable "redis_password" {
  description = "Clave de acceso de Azure Managed Redis"
  type        = string
  default     = null
  sensitive   = true
}
