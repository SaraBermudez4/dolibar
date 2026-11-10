# DoliCloud Containers — app-mysql (Dolibarr + base relacional)

Dolibarr ERP en **Azure Container Apps** con **Azure Database for MySQL Flexible Server**
(base relacional gestionada) y **Azure Files** para la carpeta `documents`. Todo con Terraform.

## Arquitectura

| Capa | Recurso | Detalle |
|---|---|---|
| Red | `azurerm_virtual_network` | 10.1.0.0/16 |
| Red | `azurerm_subnet.apps` | 10.1.0.0/23, Container Apps Environment |
| Red | `azurerm_subnet.mysql` | 10.1.2.0/24, delegada a MySQL Flexible Server |
| Red | `azurerm_private_dns_zone` | MySQL solo se resuelve dentro de la VNet |
| Relacional | `azurerm_mysql_flexible_server` | MySQL 8.0, B1ms (gratis 12 meses en Azure for Students), sin IP pública |
| Relacional | `azurerm_mysql_flexible_database` | `dolibarrdb`, utf8mb4 |
| Archivos | `azurerm_storage_account` + `azurerm_storage_share` | Azure Files montado en `/var/www/documents` |
| Contenedor | `azurerm_container_app_environment` | Plan de consumo dentro de la VNet |
| Contenedor | `azurerm_container_app` | Imagen oficial `dolibarr/dolibarr:22.0.5`, HTTPS público |

Archivos: `main.tf` (RG + red), `mysql.tf`, `storage.tf`, `app.tf`, `variables.tf`, `outputs.tf`.

## Requisitos

- Terraform >= 1.5 y Azure CLI
- Cuenta de Azure for Students (`az login`)
- Docker Desktop (solo para la prueba local)

## 1. Prueba local (opcional, sin Azure)

```bash
docker compose up -d        # http://localhost:8080  (admin / admin123)
docker compose down -v      # borra todo
```

## 2. Despliegue en Azure

```bash
az login
export TF_VAR_subscription_id="$(az account show --query id -o tsv)"
export TF_VAR_db_password='UnaClaveLarga2026'        # 12+ caracteres, mayúsculas, minúsculas y números
export TF_VAR_dolibarr_admin_password='OtraClave2026'

terraform init
terraform plan
terraform apply
```

En PowerShell, en lugar de `export`:

```powershell
$env:TF_VAR_subscription_id = (az account show --query id -o tsv)
$env:TF_VAR_db_password = 'UnaClaveLarga2026'
$env:TF_VAR_dolibarr_admin_password = 'OtraClave2026'
```

MySQL Flexible Server tarda varios minutos en crearse. Al terminar, abrir `dolibarr_url`
(la primera carga hace la instalación automática y puede tardar). Usuario: `admin`.

Logs del contenedor:

```bash
az containerapp logs show -n dolicloud-app -g dolicloud-rg --follow
```

## 3. Destruir

```bash
terraform destroy
```

## Contrato con la parte de Redis (`cache-redis`)

`app.tf` ya acepta estas variables, vacías por defecto (Dolibarr funciona sin Redis):

| Variable | Qué recibe | Se inyecta al contenedor como |
|---|---|---|
| `image` | Imagen propia de `cache-redis` en su ACR | imagen del contenedor |
| `redis_host` | Host de Azure Managed Redis | `REDIS_HOST` |
| `redis_port` | Puerto | `REDIS_PORT` |
| `redis_password` | Clave de acceso | `REDIS_PASSWORD` (secreto) |

Para la integración, `cache-redis` usa la subred `10.1.3.0/24` dentro de `vnet_name` (output).
Con Redis activo se puede subir `max_replicas` a 2.

## Decisiones de diseño

- **MySQL sin IP pública:** subred delegada + DNS privado; solo el contenedor lo alcanza.
- **TLS de MySQL desactivado** (`require_secure_transport = OFF`): el tráfico no sale de la red privada y así Dolibarr conecta sin certificados.
- **`DOLI_INSTANCE_UNIQUE_ID` fijo:** Dolibarr cifra datos con ese ID; si cambiara en cada reinicio no podría leerlos.
- **Azure Files para `documents`:** el disco del contenedor se pierde al reiniciar; los adjuntos y el `install.lock` deben persistir.
- **`max_replicas = 1` sin Redis:** con 2 réplicas y sesiones locales el usuario perdería la sesión al cambiar de réplica.
- **Secretos por `TF_VAR_*`** y como `secret` de Container Apps, nunca en `terraform.tfvars`.

## Puntos a verificar en el primer despliegue

- **Región:** Azure for Students puede bloquear MySQL Flexible en algunas regiones. Si `apply` falla por restricción de ubicación, cambiar `location` (p. ej. `eastus2`, `centralus`).
- **Permisos de Azure Files:** se monta con `uid=33` (www-data). Si Dolibarr dice que `documents` no es escribible, revisar los logs.
- **Costo:** Container Apps y MySQL B1ms están en el plan gratis; Azure Files cobra muy poco por GB. Hacer `destroy` al terminar.
