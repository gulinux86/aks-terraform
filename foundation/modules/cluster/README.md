# cluster module — private AKS, OIDC + Workload Identity, KMS, Azure RBAC

Private AKS cluster (Private Endpoint API + AKS-managed private DNS), OIDC issuer + Workload Identity, KMS etcd encryption via a customer-managed Key Vault key, Entra + Azure RBAC for Kubernetes (local accounts disabled), Azure CNI Overlay, NAT-Gateway egress, and a system node pool.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.etcd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_key.etcd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_role_assignment.cluster_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cluster_etcd_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.operator_etcd_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_admin_object_ids"></a> [cluster\_admin\_object\_ids](#input\_cluster\_admin\_object\_ids) | Entra object IDs granted AKS RBAC Cluster Admin (e.g. the CI deploy identity) | `list(string)` | `[]` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version (pin a version in standard support) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Desired number of nodes in the system node pool | `number` | n/a | yes |
| <a name="input_node_max_count"></a> [node\_max\_count](#input\_node\_max\_count) | Maximum nodes (autoscaler) | `number` | n/a | yes |
| <a name="input_node_min_count"></a> [node\_min\_count](#input\_node\_min\_count) | Minimum nodes (autoscaler) | `number` | n/a | yes |
| <a name="input_node_subnet_id"></a> [node\_subnet\_id](#input\_node\_subnet\_id) | Subnet ID for the system node pool (NAT-Gateway egress) | `string` | n/a | yes |
| <a name="input_node_vm_size"></a> [node\_vm\_size](#input\_node\_vm\_size) | VM size for the system node pool | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used to name the cluster and related resources | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group to create the cluster in | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the cluster resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | AKS cluster resource ID (consumed by the workload cluster extension) |
| <a name="output_cluster_identity_principal_id"></a> [cluster\_identity\_principal\_id](#output\_cluster\_identity\_principal\_id) | Principal ID of the cluster control-plane identity |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | AKS cluster name |
| <a name="output_kubelet_identity_object_id"></a> [kubelet\_identity\_object\_id](#output\_kubelet\_identity\_object\_id) | Object ID of the kubelet identity |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | AKS-managed node resource group |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | Cluster OIDC issuer URL (used for Workload Identity federated credentials) |
<!-- END_TF_DOCS -->