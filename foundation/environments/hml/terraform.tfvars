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
# (the CI deploy identity). Fill in after bootstrap.
cluster_admin_object_ids = []

tags = {
  Project     = "aks"
  Environment = "hml"
  ManagedBy   = "terraform"
}
