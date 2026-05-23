# Individuell prosjektoppgave

Migration of an on-premises stack (pfSense, AD DS, Docker/Django/MySQL) to Azure with Terraform. **Workload:** Azure Container Apps with **MySQL and Django** sidecar containers in **Norway East**.

App source: [rasdr/eCommerce](https://github.com/rasdr/eCommerce) (cloned and patched locally).

## If you already know AK2

Both projects use the same layout: **root `main.tf` wires modules in order**, settings go in **`terraform.tfvars`**, and each folder under `modules/` owns one part of Azure.

| AK2 (`ak2/`) | This project (`prosjektoppgave/`) | Role |
|--------------|-----------------------------------|------|
| `modules/rg/` | `modules/rg/` | One resource group for everything |
| `modules/policies/` | `modules/cost/` + `modules/monitor/` | Governance and observability |
| `modules/network/` | `modules/network/` | VNet(s), subnet, NSG (here: hub-spoke + ACA subnet) |
| `modules/lb/` | `modules/firewall/` + `modules/routing/` | Controls traffic (here: firewall + UDR instead of load balancer) |
| `modules/vmss/` | `modules/containerapps/` | Runs the app (here: containers, not VMs) |
| `cloud-init/web.yaml` | `eCommerce/` + `scripts/*.ps1` | How the app is built and configured |

**Apply order in `main.tf` (read top to bottom):**

```
resource_group → cost → monitor → network → firewall → routing → containerapps
```

Same mental model as AK2: *platform first (rg, network), then traffic control, then the workload*.

## Architecture

- **Resource Group**: All resources are created in one Azure resource group
- **Network**: Hub-spoke VNets with peering; **snet-aca** subnet delegated for Container Apps
- **NSG**: Deny SSH/RDP from the internet on the ACA subnet; allow HTTPS outbound from the subnet
- **Azure Firewall**: Basic SKU in the hub; application rules for HTTPS egress and PaaS (ACR, Docker Hub, DNS)
- **UDR**: Spoke default route (`0.0.0.0/0`) via the firewall private IP
- **Container Apps Environment**: Internal ingress disabled; workload in the spoke subnet
- **Azure Container Registry**: Images pulled with the container app system-assigned identity (`AcrPull`)
- **Container App**: **ecommerce-mysql** + **ecommerce** containers; public HTTPS ingress on port 8000
- **Log Analytics + alert**: Workspace retention and optional heartbeat metric alert to email
- **Cost budget**: Monthly resource group budget with email notifications (when `alert_email` is set)

---

## Running the Terraform code

### 1. Clone the repository

```bash
git clone https://github.com/ektealexander/terraform.git
cd terraform/prosjektoppgave
```

### 2. Prerequisites

- **Terraform** installed
- **Azure CLI** installed and signed in: `az login`
- **Azure subscription** with permissions for RG, networking, firewall, Container Apps, ACR, Monitor, and Cost Management
- **Git** (for `scripts/setup-ecommerce.ps1`)

Confirm you are signed in and using the intended subscription:

```bash
az account show
az account set --subscription "<subscription-id>"
```

### 3. Configure variables

Create or edit `terraform.tfvars` (see `variables.tf` for names and defaults).

Important:

- `subscription_id`, `mysql_app_password`, and `alert_email` are sensitive or personal values
- Do not share these in recordings or screenshots
- Do not commit `terraform.tfvars` (it is gitignored)

After the first apply, set `django_allowed_hosts` to include the FQDN from `terraform output container_app_fqdn`, then run `terraform apply` again if Django rejects the host.

### 4. Init, plan, and apply

From the `prosjektoppgave` folder (where `main.tf` lives):

```bash
terraform init
terraform plan
terraform apply
```

- `init` downloads providers and initializes modules
- `plan` shows changes without applying them
- `apply` creates the resource group, hub-spoke network, firewall, monitoring, cost budget, ACR, and Container App

Use `terraform apply -parallelism=1` if you hit Azure dependency ordering issues.

### 5. Build and push container images

After a successful apply, prepare the app and push images to ACR (PowerShell on Windows):

```powershell
.\scripts\setup-ecommerce.ps1
.\scripts\build-acr.ps1
```

`setup-ecommerce.ps1` fills `eCommerce/` from [rasdr/eCommerce](https://github.com/rasdr/eCommerce) (keeps committed Azure overrides; see `eCommerce/README.md`). `build-acr.ps1` runs `az acr build` for `ecommerce:latest` and `ecommerce-mysql:latest`.

Keep `mysql_database_name`, `mysql_admin_username`, and `mysql_app_password` in `terraform.tfvars` aligned with `db/dump/ecom3.sql` when using the sample database.

### 6. Get Container App URL

```bash
terraform output container_app_url
terraform output acr_login_server
```

Open the HTTPS URL in a browser.

---

## Prosjektoppgave modules

| Path | Purpose |
|------|---------|
| `modules/rg/` | Creates the resource group |
| `modules/network/` | Hub-spoke VNets, peering, ACA subnet, NSG |
| `modules/firewall/` | Azure Firewall, policy, and diagnostic settings |
| `modules/routing/` | Spoke route table: default route via firewall |
| `modules/monitor/` | Log Analytics workspace and optional email alert |
| `modules/cost/` | Monthly resource group consumption budget |
| `modules/containerapps/` | ACR, Container Apps environment, Django + MySQL app |

### Where to change what

| Goal | File |
|------|------|
| Subscription, region, RG name, prefix, network CIDR, firewall SKU, alerts, budget, Django/MySQL settings | `terraform.tfvars` and `variables.tf` |
| Hub-spoke layout and NSG rules | `modules/network/main.tf` |
| Firewall app/network rules and SKU wiring | `modules/firewall/main.tf` |
| Spoke UDR (0.0.0.0/0 → firewall) | `modules/routing/main.tf` |
| LAW retention and metric alert | `modules/monitor/main.tf` |
| Container images, env vars, ACA sizing | `modules/containerapps/main.tf` |
| Django/ACA settings for Azure (env-based) | `eCommerce/eCommerce/settings.py` |
| MySQL image and sample DB import | `eCommerce/db/mysql/Dockerfile` |
| Clone + patch workflow | `scripts/setup-ecommerce.ps1`, `scripts/build-acr.ps1` |

### Outputs

Defined in root `outputs.tf`:

- `resource_group_name`
- `container_app_url`
- `container_app_fqdn`
- `acr_login_server`
- `firewall_private_ip`

---

## Verifying deployment

After `terraform apply` and `.\scripts\build-acr.ps1`:

| Check | Command / action | What you want to see |
|-------|------------------|----------------------|
| Container App URL | `terraform output container_app_url` | An `https://` URL |
| Web app is reachable | Open the URL in a browser | Store page loads |
| Login / register | Use the app UI | Auth and cart work |
| ACR has images | `az acr repository list --name <acr-name>` | `ecommerce` and `ecommerce-mysql` |
| Terraform state is clean | `terraform plan` | `No changes` |
| Monitoring | Azure Portal → Log Analytics | Ingestion from ACA/firewall |
| Cost alerts | Email (if `alert_email` set) | Budget notifications at thresholds |

If the app does not start, check Container App revision logs, that images exist in ACR, and that `django_allowed_hosts` includes the app FQDN.

---

## Cleanup

Removes all resources Terraform created:

```bash
terraform destroy
```

Optional: remove extra files under `eCommerce/` that were added by `setup-ecommerce.ps1` (only Azure overrides are meant for git).
