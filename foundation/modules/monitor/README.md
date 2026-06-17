# monitor module — Log Analytics workspace (observability backplane)

Log Analytics workspace that the cluster ships to: control-plane diagnostic logs (Level 1) and Container Insights via the oms_agent (Level 2). Both are cluster-scoped and live in the cluster module (which consumes this workspace's ID), avoiding a cluster↔monitor dependency cycle.


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
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Log Analytics retention in days | `number` | `30` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used to name the Log Analytics workspace | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group to create the workspace in | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the workspace | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Log Analytics workspace ID (consumed by the cluster for diagnostics + Container Insights) |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | Log Analytics workspace name |
<!-- END_TF_DOCS -->