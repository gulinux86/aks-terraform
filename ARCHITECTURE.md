# Architecture

A private, OIDC-everywhere AKS platform that mirrors the `eks-terraform` portfolio
on Azure. The cloud-neutral shape is identical — `bootstrap` / `foundation` /
`workload` layers, partial backends per environment, OIDC-only CI, mocked-provider
tests, Trivy scanning — and the cloud-specific pieces are re-expressed in Azure
primitives. The valuable ~30% is three deliberate divergences (see below).

## AWS → Azure mapping

| AWS (eks-terraform)            | Azure (this repo)                                  |
|--------------------------------|----------------------------------------------------|
| S3 state bucket                | Storage Account + blob container                   |
| DynamoDB lock                  | blob lease (native, nothing to create)             |
| KMS CMK                        | Key Vault + key                                    |
| GitHub OIDC IAM role           | Workload Identity Federation (federated creds)     |
| VPC / subnets                  | VNet / subnets                                     |
| IGW                            | (n/a — VNet routable by default)                   |
| NAT Gateway (per-AZ)           | NAT Gateway                                         |
| EKS control plane              | AKS (private)                                      |
| IRSA (OIDC provider)           | Workload Identity (OIDC issuer + federated creds)  |
| EKS Access Entries             | Azure RBAC for Kubernetes (Entra)                  |
| KMS secrets envelope           | KMS etcd encryption (Key Vault key)                |
| VPC interface/S3 endpoints     | Private Endpoints                                  |
| Bastion + SSM                  | `az aks command invoke` (Azure Bastion optional)   |
| AWS Load Balancer Controller   | App Gateway for Containers ALB Controller (Helm via `command invoke`) |
| `public_access_cidrs`          | private cluster (no public endpoint)               |

## Three deliberate divergences from the EKS project

1. **Workload Identity replaces IRSA** — same per-workload least-privilege shape,
   different resources (user-assigned managed identity + federated credential
   bound to one `system:serviceaccount:<ns>:<sa>`). No `aws_iam_openid_connect_provider`
   analog is needed: Entra ID trusts the AKS OIDC issuer natively once
   `oidc_issuer_enabled` / `workload_identity_enabled` are on.
2. **Private cluster + `az aks command invoke`** replaces public-endpoint + CIDR
   allowlist — the API server has no public endpoint; CI drives it through the AKS
   managed tunnel, so no self-hosted runners are required.
3. **Helm via `command invoke` replaces the Terraform Helm provider** — because
   the private API is unreachable from GitHub-hosted runners, the ingress
   controller is installed by running Helm through `az aks command invoke` (the
   AKS managed tunnel), not via the Terraform `helm` provider. The
   `kubernetes`/`helm` providers are therefore dropped from `workload`.
   *(Originally planned as a managed cluster extension; that was abandoned after
   the AGC ALB Controller proved to have no supported AKS extension type —
   `command invoke` + Helm is the private-cluster-safe install path.)*

## 1. Two-layer split (`foundation` + `workload`)

`bootstrap` (one-time, local state) creates the state backend + CI identity.
`foundation` (long-lived) holds the VNet, AKS, identity, and node pool;
`workload` holds in-cluster add-ons. `workload` reads `foundation` via
`terraform_remote_state` against the `azurerm` backend. The split bounds blast
radius and keeps a clean provider boundary — unchanged from EKS because it is
cloud-neutral. Each layer is one state file per environment (modules share their
layer's state; modules do **not** have their own state).

## 2. Networking

VNet with dedicated subnets for nodes, Application Gateway for Containers (delegated
to `Microsoft.ServiceNetworking/trafficControllers`), private endpoints, and an
`AzureBastionSubnet`. There is no public/private-subnet + IGW concept; all subnets
route within the VNet. Egress is a Standard **NAT Gateway** associated with the node
subnet (`outbound_type = userAssignedNATGateway`), so nodes have no public IPs. The
network plugin is **Azure CNI Overlay** (pod CIDR separate from the VNet, less
subnet pressure than classic CNI; must be set at create time).

## 3. AKS control plane

Private cluster: API server via Private Endpoint + an AKS-managed private DNS zone
(`private_dns_zone_id = "System"`), no public FQDN. **OIDC issuer** and **Workload
Identity** are enabled. **KMS etcd encryption** uses a customer-managed Key Vault key
(the cluster's user-assigned identity is granted Key Vault Crypto User before
create, avoiding the identity↔key cycle). Authorization is **Entra + Azure RBAC for
Kubernetes** with `local_account_disabled = true`; cluster-admin is granted by Azure
role assignment to the configured object IDs (the CI identity). `sku_tier = Free`.

## 4. Compute — system node pool

The system node pool lives inline in the cluster (`default_node_pool`, AKS requires
exactly one) and is sized via variables with the autoscaler on (`Standard_B2s`
burstable default). An optional **user** node pool is a separate module
(`user_node_pool_enabled`, off by default), mirroring the EKS managed-node-group.

## 5. Identity — Workload Identity (the IRSA analog)

Each workload needing Azure permissions gets a dedicated **user-assigned managed
identity**, a **federated identity credential** binding it to exactly one
`system:serviceaccount:<ns>:<sa>` (audience `api://AzureADTokenExchange`, issuer =
the cluster OIDC issuer), and narrowly scoped **role assignments**. The service
account is annotated with the identity client ID so the Workload Identity webhook
injects a token. AAD Pod Identity is deprecated and not used.

## 6. Add-ons — ALB Controller via Helm over `command invoke`

The Application Gateway for Containers ALB Controller is installed by running its
Helm chart through `az aks command invoke` in the deploy workflow (no runner API
reachability, no Terraform helm/kubernetes provider). Terraform owns only the
Azure-side Workload Identity (§5) — the user-assigned identity, federated
credential, and scoped role assignments — and passes the identity client ID into
the Helm release. A managed cluster extension was the original plan but the AGC
ALB Controller has no supported AKS extension type (confirmed by a 400
`ExtensionTypeRegistrationGetFailed`), so the managed-tunnel Helm install is used.
Core
add-ons (CoreDNS, kube-proxy) are AKS-managed and the CNI is a cluster property, so
the EKS `eks-addons` "core add-ons as code / version-skew" effort has no Azure
counterpart — documented here rather than inventing parity busywork.

## 6.5 Observability (`monitor` module)

Toggled with `observability_enabled` (on in `hml`/`prod` tfvars). The `monitor`
module creates a Log Analytics workspace; the cluster then ships **control-plane
diagnostic logs** (Level 1 — `kube-apiserver`, `kube-audit-admin`,
`kube-controller-manager`, `kube-scheduler`, `cluster-autoscaler`, `guard`,
plus `AllMetrics`) and **Container Insights** (Level 2 — `oms_agent` with MSI
auth) to it. The diagnostic setting and `oms_agent` are cluster-scoped and live
in the `cluster` module (which consumes the workspace ID); the workspace stays in
the `monitor` module so there is no cluster↔monitor dependency cycle. This is the
Azure analog of the EKS `enabled_cluster_log_types` → CloudWatch, expanded into a
composed module because Azure observability spans several resources.

## 7. State & backend

`azurerm` backend with partial config per environment
(`resource_group_name`/`storage_account_name`/`container_name`/`key` from
`environments/<env>/backend.hcl`). Locking is the native **blob lease** — no
DynamoDB-equivalent to create. The state Storage Account disables shared keys
(`use_azuread_auth`), requires TLS 1.2, versions blobs, and is encrypted with a
**customer-managed Key Vault key**. Every Terraform principal needs Key Vault crypto
permissions on that key.

## 8. CI/CD (GitHub Actions)

GitHub → Azure via **Workload Identity Federation** (no client secret); the CI
identity's federated credentials are scoped to `environment:hml`/`environment:prod`
(deploy/destroy) and `pull_request` (plan) — no `repo:*` wildcard. Pipelines: plan
(PR comment), test (mocked `azurerm`, no creds), security-scan (Trivy `config` +
SARIF), deploy (gated by test + Trivy, `plan -out`→`apply tfplan`,
`foundation`→`workload`, prod reviewer-gated), destroy (typed confirm,
`workload`→`foundation`). In-cluster checks run via `az aks command invoke`.

## 9. Environments

`hml` and `prod`, distinct VNet CIDRs and distinct state keys. `prod` is gated by a
required reviewer on the `prod` GitHub Environment.

## 10. Cost (lean / portfolio baseline)

East US pay-as-you-go, ~730 hrs/mo:

```
 AKS control plane (Free tier)              $0
 2× Standard_B2s nodes                      ~$60
 1× NAT Gateway + public IP                 ~$36
 Private Endpoint + Private DNS zone        ~$8
 Standard Load Balancer (base)              ~$18
 App Gateway for Containers (ALB Ctrl)      ~$35 ⚠ (NGINX fallback → ~$0)
 Key Vault + Storage (state) + ops          ~$2
 Minimal control-plane logs                 ~$8
 ─────────────────────────────────────────────
 ≈ $167 / month   (≈ $132 with NGINX)
```

Under the equivalent EKS build for two structural reasons: AKS Free-tier control
plane is `$0` (vs ~$73/mo), and one Private Endpoint (~$8) replaces the EKS VPC
interface-endpoint fleet (~$73). Choosing `command invoke` over Azure Bastion
(~$140–210/mo) is the single biggest cost win.

## 11. Known trade-offs to revisit for true production

| Area | Current (portfolio) | Production-hardening step |
|------|---------------------|---------------------------|
| API access | Private + `command invoke` | + in-VNet runners / VPN for richer kubectl ergonomics |
| Egress | Single NAT Gateway | Per-zone NAT Gateways for HA egress |
| Ingress | ALB Controller extension (preview-risk ⚠) | Confirm GA in region; pin via `azapi`; or AGIC/NGINX fallback |
| Scaling | System pool autoscaler | Dedicated tainted system pool + user pool(s) / KEDA |
| Cluster add-ons | ALB Controller only | + External Secrets, cert-manager, ExternalDNS, metrics-server, policy agents |
| Private endpoints | Empty by default | Private Endpoints for the etcd/state Key Vault + ACR |
| Identity | One UAI per workload | Keep per-workload; review role-assignment scopes periodically |
| State account | Single shared account (CMK) | Per-subscription/per-env accounts + network-restricted access |
| Logs | Diagnostic logs + Container Insights via the `monitor` module (toggle) | + alert rules, managed Prometheus + Grafana, longer retention |
