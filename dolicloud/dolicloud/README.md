# DoliCloud — ERP Dolibarr como Infraestructura como Código

Despliegue automatizado del ERP **Dolibarr** sobre **Microsoft Azure** con Terraform.
Toda la infraestructura (red, cómputo, seguridad) y la instalación de la aplicación
se declaran en código: un solo `terraform apply` levanta el ERP desde cero y un
`terraform destroy` lo elimina sin dejar recursos huérfanos.

## Arquitectura

| Capa | Recurso | Detalle |
|---|---|---|
| Agrupación | `azurerm_resource_group` | contiene todo el despliegue |
| Red | `azurerm_virtual_network` | 10.1.0.0/16 |
| Red | `azurerm_subnet` | 10.1.1.0/24 |
| Red | `azurerm_network_security_group` | entrada TCP/80 y TCP/22, resto denegado |
| Red | `azurerm_public_ip` | SKU Standard, asignación estática |
| Red | `azurerm_network_interface` | une la VM, la subred y la IP pública |
| Cómputo | `azurerm_linux_virtual_machine` | Ubuntu 24.04 LTS, Standard_B1ms, disco SSD 30 GB |

La aplicación se instala con **cloud-init**
(`modules/compute/templates/cloud-init.sh.tpl`): swap de 2 GB, Apache + PHP 8.3 +
MariaDB, base de datos y usuario de Dolibarr, descarga del release fijado, virtual
host propio, permisos y `install.forced.php`.

## Requisitos

- Terraform >= 1.5
- Azure CLI (`az login`)
- Un par de llaves SSH en `~/.ssh/id_rsa` (si no existe: `ssh-keygen -t rsa -b 4096`)

## Uso

```bash
az login
export TF_VAR_subscription_id="$(az account show --query id -o tsv)"
export TF_VAR_db_password='UnaClaveLarga2026'   # >= 12 caracteres, sin comillas ni $ ` \

terraform init
terraform plan
terraform apply
```

Salidas:

```
dolibarr_install_url = "http://X.X.X.X/install/"
dolibarr_url         = "http://X.X.X.X"
ssh_command          = "ssh azureuser@X.X.X.X"
resource_group_name  = "dolicloud-rg"
```

cloud-init tarda entre 4 y 8 minutos. Seguimiento del progreso:

```bash
ssh azureuser@X.X.X.X
sudo tail -f /var/log/dolicloud-install.log
```

La última línea debe decir `Instalacion de Dolibarr terminada`.

## Instalación de Dolibarr

Al abrir `dolibarr_install_url` el asistente aparece con los datos de base de datos
ya cargados y bloqueados (`install.forced.php`). Solo hay que confirmar los pasos y
definir la contraseña del usuario `admin`. Al terminar se crea `documents/install.lock`
automáticamente, lo que bloquea el instalador.

## Destruir

```bash
terraform destroy
```

## Decisiones de diseño

**Release fijado en lugar de rama de desarrollo.** `dolibarr_version = "22.0.5"`
garantiza que dos despliegues distintos instalen exactamente el mismo código.

**`documents/` fuera del DocumentRoot.** Los archivos adjuntos del ERP (facturas,
contratos, documentos de clientes) quedan en `/var/www/dolibarr/documents`, que
Apache no sirve. Dentro del árbol web serían descargables por cualquiera que
adivinara la ruta.

**Llave SSH leída desde disco, no generada por Terraform.** El recurso
`tls_private_key` habría generado el par automáticamente, pero guarda la llave
privada en texto plano dentro de `terraform.tfstate`. Leer la llave pública del
usuario mantiene la privada fuera del estado y del repositorio.

**Contraseñas por variable de entorno.** `db_password` y `subscription_id` nunca
se escriben en `terraform.tfvars`; viajan como `TF_VAR_*` y la primera queda marcada
`sensitive`, por lo que no aparece en la salida de `plan` ni de `apply`.

**Versión del proveedor acotada.** `version = "~> 4.0"` permite parches pero bloquea
cambios mayores que romperían el despliegue sin aviso.

## Limitaciones conocidas

- `custom_data` fuerza el reemplazo de la VM: cualquier cambio al script de
  cloud-init recrea la máquina y se pierden los datos del ERP. Los ajustes en
  caliente se hacen por SSH.
- El tráfico viaja por HTTP sin cifrar. Un entorno real necesita HTTPS con
  certificado (Let's Encrypt o Azure Application Gateway).
- `http_allowed_cidrs` y `ssh_allowed_cidrs` están abiertos a internet para la
  sustentación. En producción se restringen a la IP de la organización.
- El estado de Terraform queda en un archivo local. Para trabajo en equipo se
  migra a un backend remoto (`azurerm` backend sobre Azure Storage) con bloqueo.
