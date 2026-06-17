output "workspace_id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "Log Analytics workspace ID (consumed by the cluster for diagnostics + Container Insights)"
}

output "workspace_name" {
  value       = azurerm_log_analytics_workspace.this.name
  description = "Log Analytics workspace name"
}
