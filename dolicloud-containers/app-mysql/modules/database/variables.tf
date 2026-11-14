variable "project_name" {
  description = "Prefijo para los nombres de los recursos"
  type        = string
}

variable "name_suffix" {
  description = "Sufijo aleatorio para que el nombre del servidor sea unico en Azure"
  type        = string
}

variable "location" {
  description = "Region de Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Grupo de recursos donde se crea la base"
  type        = string
}

variable "tags" {
  description = "Etiquetas aplicadas a cada recurso"
  type        = map(string)
}

variable "vnet_id" {
  description = "Red virtual que se vincula a la zona DNS privada"
  type        = string
}

variable "subnet_id" {
  description = "Subred delegada a MySQL Flexible Server"
  type        = string
}

variable "sku_name" {
  description = "Tamano del servidor MySQL"
  type        = string
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "db_username" {
  description = "Usuario administrador de MySQL"
  type        = string
}

variable "db_password" {
  description = "Clave del usuario administrador de MySQL"
  type        = string
  sensitive   = true
}
