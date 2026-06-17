project_name       = "aks-prod"
location           = "eastus"
vnet_address_space = ["10.1.0.0/16"]
kubernetes_version = "1.31"

node_vm_size   = "Standard_B2s"
node_count     = 2
node_min_count = 1
node_max_count = 3

cluster_admin_object_ids = []

tags = {
  Project     = "aks"
  Environment = "prod"
  ManagedBy   = "terraform"
}
