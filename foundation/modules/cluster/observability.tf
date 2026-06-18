# Control-plane diagnostic logs (Level 1) → Log Analytics.
#
# Cluster-scoped, so it lives with the cluster (and references cluster.id
# locally) rather than in the monitor module — which keeps the workspace module
# free of any dependency on the cluster. Created only when a workspace is wired.
resource "azurerm_monitor_diagnostic_setting" "aks" {
  count = var.observability_enabled ? 1 : 0

  name                       = "${var.project_name}-aks-diag"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "kube-apiserver" }
  enabled_log { category = "kube-audit-admin" }
  enabled_log { category = "kube-controller-manager" }
  enabled_log { category = "kube-scheduler" }
  enabled_log { category = "cluster-autoscaler" }
  enabled_log { category = "guard" }

  enabled_metric { category = "AllMetrics" }
}
