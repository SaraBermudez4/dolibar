variable "project_name" {
  description = "Prefijo para los nombres de los recursos"
  type        = string
}

variable "location" {
  description = "Region de Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Grupo de recursos donde se crea la red"
  type        = string
}

variable "tags" {
  description = "Etiquetas aplicadas a cada recurso"
  type        = map(string)
}

variable "vnet_cidr" {
  description = "Rango de la red virtual"
  type        = string
}

variable "apps_subnet_cidr" {
  description = "Rango de la subred de Container Apps"
  type        = string
}

variable "mysql_subnet_cidr" {
  description = "Rango de la subred de MySQL"
  type        = string
}
