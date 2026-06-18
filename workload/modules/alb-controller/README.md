# alb-controller module — Workload Identity for the App Gateway for Containers ALB Controller

Provisions the Azure-side identity for the ALB Controller: a dedicated user-assigned managed identity, a federated credential bound to one service account, and narrowly scoped role assignments. The controller itself is installed by Helm via `az aks command invoke` in the deploy workflow (no Terraform helm/kubernetes provider, no runner API reach) — the AGC ALB Controller has no supported AKS cluster-extension type.

/dev/stdout updated successfully
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
| [azurerm_federated_identity_credential.alb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.alb_config_manager](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.alb_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.alb_subnet_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.alb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_subnet_id"></a> [alb\_subnet\_id](#input\_alb\_subnet\_id) | Delegated subnet for Application Gateway for Containers (Network Contributor scope) | `string` | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | AKS cluster resource ID (target for the cluster extension) | `string` | n/a | yes |
| <a name="input_controller_namespace"></a> [controller\_namespace](#input\_controller\_namespace) | Namespace the ALB Controller runs in | `string` | `"azure-alb-system"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | Cluster OIDC issuer URL (federated-credential issuer) | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used to name the controller identity | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group of the cluster (scope for the controller's role assignments) | `string` | n/a | yes |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Service account the controller uses (bound by the federated credential) | `string` | `"alb-controller-sa"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the controller identity | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_controller_namespace"></a> [controller\_namespace](#output\_controller\_namespace) | Namespace the ALB Controller is installed into (Helm --namespace) |
| <a name="output_identity_client_id"></a> [identity\_client\_id](#output\_identity\_client\_id) | Client ID of the ALB Controller identity (passed to the Helm release: albController.podIdentity.clientID) |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | namespace/name of the controller service account |
| <a name="output_service_account_name"></a> [service\_account\_name](#output\_service\_account\_name) | Service account bound by the federated credential (must match the chart's SA) |
<!-- END_TF_DOCS -->