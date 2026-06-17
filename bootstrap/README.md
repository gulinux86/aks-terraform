# bootstrap

One-time, per-subscription layer (local state). Creates:

- **State backend** — Resource Group + Storage Account + blob container for the
  `foundation`/`workload` remote state. Locking is the native **blob lease** (no
  separate lock table). The Storage Account is encrypted with a **customer-managed
  key** from Key Vault.
- **CI identity** — a user-assigned managed identity with **federated credentials**
  for GitHub Actions (Workload Identity Federation, no client secret), scoped by
  environment/ref.

```bash
terraform -chdir=bootstrap init
terraform -chdir=bootstrap apply \
  -var storage_account_name="<globally-unique-name>"
```

> Every principal that runs Terraform needs Key Vault crypto permissions on the
> state CMK, otherwise state reads/writes fail.

After apply, set the outputs as GitHub Actions repository **variables** for the
pipelines: `AZURE_CLIENT_ID` (`ci_client_id`), `AZURE_TENANT_ID`, and
`AZURE_SUBSCRIPTION_ID`. Feed `ci_principal_id` into the foundation
`cluster_admin_object_ids` so CI can drive the cluster, and the
`state_*` outputs into each layer's `environments/<env>/backend.hcl`.
