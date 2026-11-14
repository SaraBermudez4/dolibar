# DoliCloud Containers — app-mysql

Dolibarr ERP en **Azure Container Apps** con **Azure Database for MySQL Flexible Server**
(base relacional gestionada) y **Azure Files** para la carpeta `documents`. Todo con Terraform,
organizado en módulos.

## Estructura

```
app-mysql/
├── main.tf              # proveedor, grupo de recursos, sufijo aleatorio y llamada a los módulos
├── variables.tf         # variables de entrada del proyecto
├── outputs.tf           # URL de Dolibarr, host de MySQL, grupo de recursos y VNet
├── versions.tf          # versiones de Terraform y proveedores
├── terraform.tfvars     # valores no secretos
├── docker-compose.yml   # prueba local: Dolibarr + MySQL 8
└── modules/
    ├── networking/      # VNet + subred de Container Apps + subred de MySQL (ambas delegadas)
    ├── database/        # zona DNS privada, MySQL Flexible Server, base dolibarrdb, parámetro TLS
    ├── storage/         # cuenta de almacenamiento + recurso compartido documents (Azure Files)
    └── compute/         # Container Apps Environment, almacenamiento del entorno y Container App
```

Cada módulo tiene su `main.tf`, `variables.tf` y `outputs.tf`. Las dependencias entre módulos
pasan por sus salidas:

| Módulo | Recibe | Entrega |
|---|---|---|
| `networking` | rangos de red | `vnet_id`, `apps_subnet_id`, `mysql_subnet_id` |
| `database` | `vnet_id`, `mysql_subnet_id`, credenciales | `fqdn`, `db_name` |
| `storage` | prefijo y sufijo de nombres | `account_name`, `account_key`, `share_name` |
| `compute` | subred, datos de MySQL, Azure Files, imagen, variables de Redis | `app_url` |

## Arquitectura

| Capa | Recurso | Detalle |
|---|---|---|
| Red | `azurerm_virtual_network` | 10.1.0.0/16 |
| Red | `azurerm_subnet.apps` | 10.1.0.0/23, delegada a `Microsoft.App/environments` |
| Red | `azurerm_subnet.mysql` | 10.1.2.0/24, delegada a MySQL Flexible Server |
| Relacional | `azurerm_private_dns_zone` + enlace | MySQL solo se resuelve dentro de la VNet |
| Relacional | `azurerm_mysql_flexible_server` | MySQL 8.0, B1ms, sin IP pública, 7 días de backup |
| Relacional | `azurerm_mysql_flexible_database` | `dolibarrdb`, utf8mb4 |
| Archivos | `azurerm_storage_account` + `azurerm_storage_share` | Azure Files montado en `/var/www/documents` |
| Contenedor | `azurerm_container_app_environment` | perfil Consumption dentro de la VNet |
| Contenedor | `azurerm_container_app` | Dolibarr, HTTPS público |

## Despliegue (PowerShell)

```powershell
az login
$env:TF_VAR_subscription_id = (az account show --query id -o tsv)
$env:TF_VAR_db_password = 'UnaClaveLarga2026'        # 12+ caracteres, mayúsculas, minúsculas y números
$env:TF_VAR_dolibarr_admin_password = 'OtraClave2026'

terraform init
terraform plan      # Plan: 16 to add
terraform apply
terraform output dolibarr_url
```

Para destruir: `terraform destroy`.

## Integración con Redis

El módulo `compute` acepta `redis_host`, `redis_port` y `redis_password`, vacías por defecto
(Dolibarr funciona sin Redis). En la integración se llenan con las salidas del proyecto de Redis,
se cambia `image` por la imagen del ACR y se puede subir `max_replicas`.

## Decisiones de diseño

- **Módulos por componente:** cada parte (red, base, almacenamiento, contenedor) declara sus entradas y salidas, y se puede reutilizar o probar por separado.
- **MySQL sin IP pública:** subred delegada + DNS privado; solo el contenedor lo alcanza.
- **TLS de MySQL desactivado** (`require_secure_transport = OFF`): el tráfico no sale de la red privada.
- **`DOLI_INSTANCE_UNIQUE_ID` fijo:** Dolibarr cifra datos con ese ID; si cambiara en cada reinicio no podría leerlos.
- **Azure Files para `documents`:** el disco del contenedor se pierde al reiniciar; adjuntos e `install.lock` deben persistir.
- **Secretos por `TF_VAR_*`** y como `secret` de Container Apps, nunca en `terraform.tfvars`.
