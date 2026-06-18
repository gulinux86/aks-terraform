project_name       = "aks-prod"
location           = "eastus"
vnet_address_space = ["10.1.0.0/16"]
kubernetes_version = "1.34"

# Constrained by the same 4 vCPU subscription quota as hml; raise quota for real prod sizing.
node_vm_size   = "Standard_D2s_v7"
node_count     = 1
node_min_count = 1
node_max_count = 2

# cluster_admin_object_ids is intentionally NOT set here. It is injected by CI
# via TF_VAR_cluster_admin_object_ids (GitHub variable AKS_CLUSTER_ADMIN_OBJECT_IDS)
# so the principal ID stays out of the public repo. Defaults to [] without it.
# Do NOT add it here: tfvars has higher precedence than TF_VAR and would override CI.

# Observability: Log Analytics + control-plane diagnostics (L1) + Container Insights (L2).
observability_enabled = true
log_retention_days    = 90

tags = {
  Project     = "aks"
  Environment = "prod"
  ManagedBy   = "terraform"
}
