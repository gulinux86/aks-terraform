# workload

In-cluster add-ons. Reads `foundation` outputs via `terraform_remote_state`, so
**`foundation` must be applied first**.

Today: the **Application Gateway for Containers ALB Controller**, installed as a
**managed cluster extension** (deployed by the Azure control plane), authorized via
**Workload Identity**. The Terraform `kubernetes`/`helm` providers are deliberately
absent — a private API server is unreachable from GitHub-hosted runners.

```bash
terraform -chdir=workload init  -backend-config=environments/hml/backend.hcl
terraform -chdir=workload plan  -var-file=environments/hml/terraform.tfvars
terraform -chdir=workload apply -var-file=environments/hml/terraform.tfvars
```

> `terraform.tfvars` here carries the `foundation_state_*` coordinates so the
> layer can read foundation's remote state. Update `akstfstateCHANGEME` to the
> Storage Account created by `bootstrap`.
