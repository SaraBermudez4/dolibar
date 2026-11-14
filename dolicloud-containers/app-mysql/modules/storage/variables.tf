variable "project_name" {
  description = "Prefijo para los nombres de los recursos"
  type        = string
}

variable "name_suffix" {
  description = "Sufijo aleatorio para que el nombre de la cuenta sea unico en Azure"
  type        = string
}

variable "location" {
  description = "Region de Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Grupo de recursos donde se crea el almacenamiento"
  type        = string
}

variable "tags" {
  description = "Etiquetas aplicadas a cada recurso"
  type        = map(string)
}
