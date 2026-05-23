# =============================================================================
# module: cost - monthly rg spend budget
# changes: root terraform.tfvars (cost_budget_amount, alert_email)
# budget is skipped when alert_email is empty (count = 0)
# =============================================================================

locals {
  budget_start = formatdate("YYYY-MM-01'T'00:00:00'Z'", plantimestamp())
  budget_end   = formatdate("YYYY-MM-01'T'00:00:00'Z'", timeadd(plantimestamp(), "8760h")) # +8760h ≈ 1 year
}

resource "azurerm_consumption_budget_resource_group" "main" {
  count = var.alert_email != "" ? 1 : 0

  name              = "${var.name_prefix}-budget-monthly"
  resource_group_id = var.resource_group_id

  amount     = var.cost_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = local.budget_start
    end_date   = local.budget_end
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    threshold      = 90
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = [var.alert_email]
  }
}
