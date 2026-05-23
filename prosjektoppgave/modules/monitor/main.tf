# =============================================================================
# module: monitor - log analytics workspace + optional email alert
# changes: root terraform.tfvars (law_retention_days, alert_email)
# =============================================================================

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name_prefix}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
}

resource "azurerm_monitor_action_group" "email" {
  count = var.alert_email != "" ? 1 : 0

  name                = "${var.name_prefix}-ag-email"
  resource_group_name = var.resource_group_name
  short_name          = "prosjalert"
  email_receiver {
    name          = "student"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "law_ingestion" {
  name                = "${var.name_prefix}-alert-law-heartbeat"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_log_analytics_workspace.main.id]
  description         = "alert if log analytics stops receiving data (indirect platform heartbeat)."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  criteria {
    metric_namespace = "Microsoft.OperationalInsights/workspaces"
    metric_name      = "Heartbeat"
    aggregation      = "Total"
    operator         = "LessThan"
    threshold        = 1
  }

  dynamic "action" {
    for_each = var.alert_email != "" ? [1] : []
    content {
      action_group_id = azurerm_monitor_action_group.email[0].id
    }
  }
}
