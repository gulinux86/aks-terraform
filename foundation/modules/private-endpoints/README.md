# private-endpoints module — private endpoints + DNS

Generic private-endpoint + private-DNS factory for PaaS dependencies (e.g. the etcd/state Key Vault), mirroring the EKS vpc-endpoints module. Driven by a map; empty by default. The AKS API server's own private endpoint is AKS-managed.

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
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | Map of PaaS dependencies to expose via a private endpoint. Each entry creates<br/>a private endpoint + a private DNS zone (linked to the VNet). Example:<br/>  { keyvault = {<br/>      target\_resource\_id = "<kv id>"<br/>      subresource\_names   = ["vault"]<br/>      dns\_zone\_name       = "privatelink.vaultcore.azure.net"<br/>  } }<br/>The AKS API server's own private endpoint is managed by AKS (private\_dns\_zone\_id<br/>= "System") and is NOT configured here. | <pre>map(object({<br/>    target_resource_id = string<br/>    subresource_names  = list(string)<br/>    dns_zone_name      = string<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group to create the private endpoints in | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID hosting the private endpoint NICs | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the private-endpoint resources | `map(string)` | n/a | yes |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | VNet ID to link the private DNS zones to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | Map of created private DNS zone IDs, keyed by zone name |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of created private endpoint IDs, keyed by the input map key |
<!-- END_TF_DOCS -->