# node-pool module — optional user node pool

Optional additional USER node pool (azurerm_kubernetes_cluster_node_pool). The system pool lives inline in the cluster module; this mirrors the EKS managed-node-group as a separate, composable module and is off by default.

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
| [azurerm_kubernetes_cluster_node_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#input\_kubernetes\_cluster\_id) | ID of the AKS cluster to attach this node pool to | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Orchestrator version for the node pool | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Node pool name (lowercase alphanumeric, <= 12 chars) | `string` | `"user"` | no |
| <a name="input_node_max_count"></a> [node\_max\_count](#input\_node\_max\_count) | Maximum nodes (autoscaler) | `number` | n/a | yes |
| <a name="input_node_min_count"></a> [node\_min\_count](#input\_node\_min\_count) | Minimum nodes (autoscaler) | `number` | n/a | yes |
| <a name="input_node_subnet_id"></a> [node\_subnet\_id](#input\_node\_subnet\_id) | Subnet ID for the node pool (NAT-Gateway egress) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the node pool | `map(string)` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | VM size for the node pool | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_pool_id"></a> [node\_pool\_id](#output\_node\_pool\_id) | ID of the user node pool |
<!-- END_TF_DOCS -->