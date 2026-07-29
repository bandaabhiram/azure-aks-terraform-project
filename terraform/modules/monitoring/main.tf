resource "azurerm_log_analytics_workspace" "this" {
name                = "${var.name_prefix}-law"
location            = var.location
resource_group_name = var.resource_group_name
sku                 = "PerGB2018"
retention_in_days   = 30
tags                = var.tags
}

resource "azurerm_monitor_action_group" "this" {
name                = "${var.name_prefix}-alerts"
resource_group_name = var.resource_group_name
short_name          = "aksalerts"
tags                = var.tags
}
