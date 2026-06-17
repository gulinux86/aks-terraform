# bastion module — OPTIONAL Azure Bastion

OPTIONAL Azure Bastion for interactive human access. Off by default — `az aks command invoke` covers CI, and Bastion is ~$140-210/mo. Kept as a hardening/ops add-on.

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
| [azurerm_bastion_host.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_public_ip.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used to name the bastion resources | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group to create the bastion in | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | Bastion SKU (Basic or Standard) | `string` | `"Basic"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | AzureBastionSubnet ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the bastion resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_fqdn"></a> [bastion\_fqdn](#output\_bastion\_fqdn) | Bastion DNS name |
| <a name="output_bastion_id"></a> [bastion\_id](#output\_bastion\_id) | Azure Bastion host ID |
<!-- END_TF_DOCS -->