# ------------------------------------------------------------------------------
# Contenedor: Azure Container Apps (plan de consumo, dentro de la VNet).
# ------------------------------------------------------------------------------
resource "azurerm_container_app_environment" "main" {
  name                     = "${var.project_name}-env"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  infrastructure_subnet_id = azurerm_subnet.apps.id
  tags                     = local.tags

  # Perfil de consumo: se paga solo por uso y entra en la cuota gratis mensual.
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

resource "azurerm_container_app_environment_storage" "documents" {
  name                         = "documents"
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = azurerm_storage_account.docs.name
  share_name                   = azurerm_storage_share.documents.name
  access_key                   = azurerm_storage_account.docs.primary_access_key
  access_mode                  = "ReadWrite"
}

# Dolibarr cifra datos con este ID; si cambiara en cada reinicio o replica,
# los valores cifrados dejarian de leerse. Se fija una sola vez.
resource "random_password" "instance_id" {
  length  = 32
  special = false
}

locals {
  app_name = "${var.project_name}-app"
  app_url  = "https://${local.app_name}.${azurerm_container_app_environment.main.default_domain}"
}

resource "azurerm_container_app" "dolibarr" {
  name                         = local.app_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  tags                         = local.tags

  secret {
    name  = "db-password"
    value = var.db_password
  }

  secret {
    name  = "admin-password"
    value = var.dolibarr_admin_password
  }

  secret {
    name  = "instance-id"
    value = random_password.instance_id.result
  }

  dynamic "secret" {
    for_each = local.redis_enabled ? [1] : []
    content {
      name  = "redis-password"
      value = var.redis_password
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    volume {
      name          = "documents"
      storage_name  = azurerm_container_app_environment_storage.documents.name
      storage_type  = "AzureFile"
      mount_options = "dir_mode=0777,file_mode=0777,uid=33,gid=33"
    }

    container {
      name   = "dolibarr"
      image  = var.image
      cpu    = 0.5
      memory = "1Gi"

      volume_mounts {
        name = "documents"
        path = "/var/www/documents"
      }

      env {
        name  = "DOLI_DB_TYPE"
        value = "mysqli"
      }
      env {
        name  = "DOLI_DB_HOST"
        value = azurerm_mysql_flexible_server.main.fqdn
      }
      env {
        name  = "DOLI_DB_HOST_PORT"
        value = "3306"
      }
      env {
        name  = "DOLI_DB_NAME"
        value = azurerm_mysql_flexible_database.dolibarr.name
      }
      env {
        name  = "DOLI_DB_USER"
        value = var.db_username
      }
      env {
        name        = "DOLI_DB_PASSWORD"
        secret_name = "db-password"
      }
      env {
        name  = "DOLI_URL_ROOT"
        value = local.app_url
      }
      env {
        name  = "DOLI_ADMIN_LOGIN"
        value = var.dolibarr_admin_login
      }
      env {
        name        = "DOLI_ADMIN_PASSWORD"
        secret_name = "admin-password"
      }
      env {
        name        = "DOLI_INSTANCE_UNIQUE_ID"
        secret_name = "instance-id"
      }
      env {
        name  = "DOLI_INSTALL_AUTO"
        value = "1"
      }
      env {
        name  = "PHP_INI_DATE_TIMEZONE"
        value = var.php_timezone
      }

      # Contrato con cache-redis: solo se agregan si hay Redis.
      dynamic "env" {
        for_each = local.redis_enabled ? { REDIS_HOST = var.redis_host, REDIS_PORT = tostring(var.redis_port) } : {}
        content {
          name  = env.key
          value = env.value
        }
      }
      dynamic "env" {
        for_each = local.redis_enabled ? [1] : []
        content {
          name        = "REDIS_PASSWORD"
          secret_name = "redis-password"
        }
      }
    }
  }

  depends_on = [
    azurerm_mysql_flexible_database.dolibarr,
    azurerm_mysql_flexible_server_configuration.no_tls,
  ]
}
