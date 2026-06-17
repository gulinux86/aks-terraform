# monitor module — observability backplane.
#
# Holds the Log Analytics workspace that the cluster ships to: control-plane
# diagnostic logs (Level 1) and Container Insights via the oms_agent (Level 2).
# Both of those are CLUSTER-scoped and therefore live in the cluster module
# (which consumes this workspace's ID) — keeping them out of here avoids a
# cluster <-> monitor module dependency cycle. This module stays the reusable
# sink and is where managed Prometheus / data collection rules would later go.

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.project_name}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}
