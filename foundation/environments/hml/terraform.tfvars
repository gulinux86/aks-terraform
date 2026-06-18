project_name       = "aks-hml"
location           = "eastus"
vnet_address_space = ["10.0.0.0/16"]
kubernetes_version = "1.34"

# Burstable, cheap portfolio default. Standard_B2s = 2 vCPU / 4 GiB.
node_vm_size   = "Standard_B2s"
node_count     = 2
node_min_count = 1
node_max_count = 3

# cluster_admin_object_ids is intentionally NOT set here. It is injected by CI
# via TF_VAR_cluster_admin_object_ids (GitHub variable AKS_CLUSTER_ADMIN_OBJECT_IDS)
# so the principal ID stays out of the public repo. Defaults to [] without it.
# Do NOT add it here: tfvars has higher precedence than TF_VAR and would override CI.

# Observability: Log Analytics + control-plane diagnostics (L1) + Container Insights (L2).
observability_enabled = true
log_retention_days    = 30

tags = {
  Project     = "aks"
  Environment = "hml"
  ManagedBy   = "terraform"
}
