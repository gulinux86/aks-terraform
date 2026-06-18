project_name       = "aks-hml"
location           = "eastus"
vnet_address_space = ["10.0.0.0/16"]
kubernetes_version = "1.31"

# Burstable, cheap portfolio default. Standard_B2s = 2 vCPU / 4 GiB.
node_vm_size   = "Standard_B2s"
node_count     = 2
node_min_count = 1
node_max_count = 3

# Entra object IDs granted AKS cluster-admin via Azure RBAC for Kubernetes
# (the CI deploy identity — bootstrap output ci_principal_id).
cluster_admin_object_ids = ["cf4be246-4a0d-4a2e-a4c3-6efdb08370cd"]

# Observability: Log Analytics + control-plane diagnostics (L1) + Container Insights (L2).
observability_enabled = true
log_retention_days    = 30

tags = {
  Project     = "aks"
  Environment = "hml"
  ManagedBy   = "terraform"
}
