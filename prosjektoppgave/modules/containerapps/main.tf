# =============================================================================
# module: containerapps - acr, aca environment, django + mysql containers
# changes: root terraform.tfvars (django_*, mysql_*, app_target_port)
# images: scripts/setup-ecommerce.ps1 then scripts/build-acr.ps1 (after apply)
# =============================================================================

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_password" "django_secret" {
  length  = 50
  special = true
}

resource "random_password" "mysql_admin" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  name_slug = substr(replace(var.name_prefix, "-", ""), 0, 12)

  database_url = format(
    "mysql://%s:%s@127.0.0.1:3306/%s",
    var.mysql_admin_username,
    urlencode(var.mysql_app_password),
    var.mysql_database_name
  )
  django_image = "${azurerm_container_registry.main.login_server}/${var.django_container_image}"
  mysql_image  = "${azurerm_container_registry.main.login_server}/${var.mysql_container_image}"
}

resource "azurerm_container_registry" "main" {
  name                = "${local.name_slug}acr${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_container_app_environment" "main" {
  name                           = "${var.name_prefix}-cae"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  infrastructure_subnet_id       = var.subnet_id_aca
  internal_load_balancer_enabled = false
}

resource "azurerm_container_app" "ecommerce" {
  name                         = "${var.name_prefix}-aca-${random_string.suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  ingress {
    external_enabled = true
    target_port      = var.app_target_port
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = "system"
  }

  template {
    min_replicas = 1
    max_replicas = 2

    container {
      name   = "mysql"
      image  = local.mysql_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "MYSQL_ROOT_PASSWORD"
        value = random_password.mysql_admin.result
      }
    }

    container {
      name   = "django"
      image  = local.django_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "MYSQL_ROOT_PASSWORD"
        value = random_password.mysql_admin.result
      }
      env {
        name  = "DATABASE_URL"
        value = local.database_url
      }
      env {
        name  = "SECRET_KEY"
        value = random_password.django_secret.result
      }
      env {
        name  = "ALLOWED_HOSTS"
        value = var.allowed_hosts
      }
      env {
        name  = "DEBUG"
        value = "False"
      }
    }
  }

  depends_on = [azurerm_container_app_environment.main]
}

resource "azurerm_role_assignment" "aca_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.ecommerce.identity[0].principal_id
}
