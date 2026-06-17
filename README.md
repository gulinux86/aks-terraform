# aks-terraform

Provisioning of a **private Azure AKS** cluster with Terraform, organized into two
independent state layers (`foundation` and `workload`) over a one-time `bootstrap`,
and shipped with a GitHub Actions CI/CD pipeline.

This is the **Azure/AKS** sibling of the [`eks-terraform`](../eks-terraform)
project — the same production-shaped, security-conscious architecture expressed in
Azure primitives. The design, the AWS→Azure mapping, and the trade-offs are
captured in the OpenSpec change `aks-azure-platform` (proposal + design) and will
be promoted into `ARCHITECTURE.md` as the layers are built.

> **Status:** scaffold. Directory structure, providers, backends, and
> per-environment inputs are in place; resources are implemented per the task
> plan (see the `aks-azure-platform` change in the `eks-terraform` repo).

## Architecture at a glance

```
        aks-terraform/   (this repo)
┌────────────────────────────────────────────────────────────────────────┐
│ bootstrap     Storage Account + container (blob-lease lock) + Key Vault  │
│               CMK + GitHub Workload Identity Federation (no secret)       │
├────────────────────────────────────────────────────────────────────────┤
│ foundation                                                               │
│   VNet ── subnets (nodes, app-gw, bastion, private-endpoints)            │
│   NAT Gateway egress                                                     │
│   AKS  ── PRIVATE cluster (API via Private Endpoint + private DNS)       │
│        ── OIDC issuer + Workload Identity                                │
│        ── KMS etcd encryption (Key Vault key)                            │
│        ── Azure RBAC for Kubernetes                                      │
│        ── system node pool                                              │
├────────────────────────────────────────────────────────────────────────┤
│ workload                                                                 │
│   App Gateway for Containers + ALB Controller (managed cluster extension)│
└────────────────────────────────────────────────────────────────────────┘

  foundation/  ──(terraform_remote_state)──▶  workload/
  CI:  GitHub → azure/login (federated) ;  kubectl via `az aks command invoke`
```

## Layers

| Layer        | Responsibility                                                                 | State                                  |
|--------------|--------------------------------------------------------------------------------|----------------------------------------|
| `bootstrap`  | One-time per subscription: Storage Account **state backend** (Key Vault CMK) + GitHub **federated CI identity** | local state |
| `foundation` | VNet, subnets, NAT, AKS (private), OIDC issuer, KMS encryption, Azure RBAC, node pool | `foundation/<env>/terraform.tfstate` |
| `workload`   | Cluster add-ons — the ALB Controller (App Gateway for Containers) as a managed extension | `workload/<env>/terraform.tfstate` |

`bootstrap` runs once to create the backend the other layers use. `workload` reads
`foundation` outputs via `terraform_remote_state`, so **`foundation` is always
applied before `workload`**.

## Prerequisites

- Terraform `~> 1.10`
- Azure CLI (`az`) authenticated to the target subscription
- A Storage Account for state (see `environments/<env>/backend.hcl`)

## Usage

Each layer uses a partial backend: `resource_group_name` / `storage_account_name`
/ `container_name` / `key` come from `environments/<env>/backend.hcl`.

```bash
# 0) bootstrap (one-time per subscription): state Storage Account + CI identity
terraform -chdir=bootstrap init
terraform -chdir=bootstrap apply

# 1) foundation
terraform -chdir=foundation init  -backend-config=environments/hml/backend.hcl
terraform -chdir=foundation plan  -var-file=environments/hml/terraform.tfvars
terraform -chdir=foundation apply -var-file=environments/hml/terraform.tfvars

# 2) workload (after foundation exists)
terraform -chdir=workload init  -backend-config=environments/hml/backend.hcl
terraform -chdir=workload plan  -var-file=environments/hml/terraform.tfvars
terraform -chdir=workload apply -var-file=environments/hml/terraform.tfvars
```

Swap `hml` for `prod` for the production environment.

### Cluster access (private API)

The API server is private; there is no public endpoint. Run in-cluster commands
through the AKS managed tunnel — no network line-of-sight required:

```bash
az aks command invoke \
  --resource-group <rg> --name <cluster-name> \
  --command "kubectl get nodes"
```

## Repository layout

```
bootstrap/                # one-time: state Storage Account + Key Vault CMK + CI identity (local state)
foundation/
  provider.tf  backend.tf  variables.tf  outputs.tf  main.tf  README.md
  environments/{hml,prod}/{terraform.tfvars,backend.hcl}
  modules/{network,cluster,node-pool,bastion,private-endpoints}/
workload/
  provider.tf  backend.tf  variables.tf  outputs.tf  main.tf  README.md
  environments/{hml,prod}/{terraform.tfvars,backend.hcl}
  modules/alb-controller/
.github/workflows/        # plan, test, security-scan, deploy, destroy (Azure variants)
.trivyignore              # documented, accepted Trivy exceptions
ARCHITECTURE.md
```
