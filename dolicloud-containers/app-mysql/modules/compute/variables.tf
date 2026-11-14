variable "project_name" {
  description = "Prefijo para los nombres de los recursos"
  type        = string
}

variable "location" {
  description = "Region de Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Grupo de recursos donde se crea el contenedor"
  type        = string
}

variable "tags" {
  description = "Etiquetas aplicadas a cada recurso"
  type        = map(string)
}

variable "subnet_id" {
  description = "Subred delegada a Container Apps"
  type        = string
}

variable "storage_account_name" {
  description = "Cuenta de almacenamiento de Azure Files"
  type        = string
}

variable "storage_account_key" {
  description = "Clave de la cuenta de almacenamiento"
  type        = string
  sensitive   = true
}

variable "storage_share_name" {
  description = "Recurso compartido que se monta en /var/www/documents"
  type        = string
}

variable "db_host" {
  description = "Host privado de MySQL"
  type        = string
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "db_username" {
  description = "Usuario de MySQL"
  type        = string
}

variable "db_password" {
  description = "Clave de MySQL"
  type        = string
  sensitive   = true
}

variable "image" {
  description = "Imagen del contenedor de Dolibarr"
  type        = string
}

variable "dolibarr_admin_login" {
  description = "Usuario administrador de Dolibarr"
  type        = string
}

variable "dolibarr_admin_password" {
  description = "Clave del usuario administrador de Dolibarr"
  type        = string
  sensitive   = true
}

variable "php_timezone" {
  description = "Zona horaria de PHP"
  type        = string
}

variable "min_replicas" {
  description = "Replicas minimas"
  type        = number
}

variable "max_replicas" {
  description = "Replicas maximas"
  type        = number
}

variable "redis_host" {
  description = "Host de Azure Managed Redis (null = sin Redis)"
  type        = string
}

variable "redis_port" {
  description = "Puerto de Azure Managed Redis"
  type        = number
}

variable "redis_password" {
  description = "Clave de Azure Managed Redis"
  type        = string
  sensitive   = true
}
