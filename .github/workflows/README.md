# CI/CD workflows (Azure variants)

Ported from `eks-terraform/.github/workflows`, adapted for Azure. Auth is GitHub →
Azure via **Workload Identity Federation** (no client secret); in-cluster steps run
through **`az aks command invoke`**, so the API server stays private.

| Workflow                | Trigger                  | Purpose                                                                 |
|-------------------------|--------------------------|-------------------------------------------------------------------------|
| `terraform-plan.yml`    | PR + `workflow_dispatch` | `azure/login` (federated) + `fmt`/`validate`/`plan` matrix over `foundation`/`workload`; posts the plan as a PR comment; skips the `workload` plan when `foundation` has no outputs yet |
| `terraform-test.yml`    | PR + `workflow_dispatch` | native `terraform test`, mocked `azurerm` providers (`-backend=false`), no Azure creds |
| `security-scan.yml`     | PR + `workflow_dispatch` | Trivy `config` mode; SARIF upload to the Security tab; gate fails on HIGH/CRITICAL |
| `terraform-deploy.yml`  | `workflow_dispatch`      | gated by test + Trivy; `plan -out` then `apply tfplan`; `foundation`→`workload`; verifies the ALB Controller via `command invoke`; prod reviewer-gated |
| `terraform-destroy.yml` | `workflow_dispatch`      | typed confirmation; `workload`→`foundation`; prod reviewer-gated         |

## Required GitHub configuration

Set these from the `bootstrap` outputs (non-secret — repository **variables**):

| Variable                 | Source (`bootstrap` output) |
|--------------------------|-----------------------------|
| `AZURE_CLIENT_ID`        | `ci_client_id`              |
| `AZURE_TENANT_ID`        | `tenant_id`                 |
| `AZURE_SUBSCRIPTION_ID`  | `subscription_id`           |

Create GitHub **Environments** `hml` and `prod` (add a required reviewer to `prod`).
The CI identity's federated credentials match `environment:hml` / `environment:prod`
for deploy/destroy and `pull_request` for plan — so only those subjects can federate.

Terraform authenticates to the `azurerm` backend and provider via OIDC
(`ARM_USE_OIDC=true` + the `ARM_CLIENT_ID`/`ARM_TENANT_ID`/`ARM_SUBSCRIPTION_ID`
env wired from the variables above).
