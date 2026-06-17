# foundation

Long-lived infrastructure: VNet + subnets + NAT Gateway egress, a **private** AKS
cluster (API via Private Endpoint + private DNS) with the OIDC issuer + Workload
Identity enabled, KMS etcd encryption (Key Vault key), Azure RBAC for Kubernetes,
and a system node pool.

```bash
terraform -chdir=foundation init  -backend-config=environments/hml/backend.hcl
terraform -chdir=foundation plan  -var-file=environments/hml/terraform.tfvars
terraform -chdir=foundation apply -var-file=environments/hml/terraform.tfvars
```

## Modules

| Module               | Responsibility                                              |
|----------------------|-------------------------------------------------------------|
| `network`            | VNet, subnets (nodes / app-gw / private-endpoints / bastion), NAT Gateway |
| `cluster`            | Private AKS, OIDC issuer + Workload Identity, KMS encryption, Azure RBAC |
| `node-pool`          | System node pool                                            |
| `private-endpoints`  | Private endpoints + private DNS zones                       |
| `bastion`            | **Optional** Azure Bastion (off by default — `command invoke` covers CI) |
| `monitor`            | **Optional** Log Analytics workspace (observability backplane) — off by default |

> An additional user node pool is available via `user_node_pool_enabled = true`
> (off by default; the system pool runs workloads in the lean baseline).
>
> Observability is enabled with `observability_enabled = true`: it creates a Log
> Analytics workspace (`monitor` module) and turns on control-plane diagnostic
> logs (Level 1) + Container Insights / `oms_agent` (Level 2) on the cluster. On
> by default in the `hml`/`prod` tfvars.
