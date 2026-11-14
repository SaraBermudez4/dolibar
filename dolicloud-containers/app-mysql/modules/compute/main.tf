# Contenedor: Azure Container Apps (perfil de consumo, dentro de la VNet).
resource "azurerm_container_app_environment" "main" {
  name                     = "${var.project_name}-env"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  infrastructure_subnet_id = var.subnet_id
  tags                     = var.tags

  # Perfil de consumo: se paga solo por uso.
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

resource "azurerm_container_app_environment_storage" "documents" {
  name                         = "documents"
  container_app_environment_id = azurerm_container_app_environment.main.id
  account_name                 = var.storage_account_name
  share_name                   = var.storage_share_name
  access_key                   = var.storage_account_key
  access_mode                  = "ReadWrite"
}

# Dolibarr cifra datos con este ID; si cambiara en cada reinicio o replica,
# los valores cifrados dejarian de leerse. Se fija una sola vez.
resource "random_password" "instance_id" {
  length  = 32
  special = false
}

locals {
  app_name      = "${var.project_name}-app"
  app_url       = "https://${local.app_name}.${azurerm_container_app_environment.main.default_domain}"
  redis_enabled = var.redis_host != null
}

resource "azurerm_container_app" "dolibarr" {
  name                         = local.app_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  tags                         = var.tags

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
        value = var.db_host
      }
      env {
        name  = "DOLI_DB_HOST_PORT"
        value = "3306"
      }
      env {
        name  = "DOLI_DB_NAME"
        value = var.db_name
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

      # Variables de Redis: solo se agregan si se pasa redis_host.
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
}
