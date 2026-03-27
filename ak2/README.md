# ST - Arbeidskrav 2

## Architecture

- **Resource Group**: All resources are created in one Azure resource group
- **Network**: One VNet and subnet with NSG rules for web traffic and VMSS access
- **Load Balancer**: Standard Public Load Balancer with frontend IP, backend pool, health probe, and rule
- **VM Scale Set**: Ubuntu 22.04 Linux VMSS connected to subnet and LB backend pool
- **Cloud-init**: `cloud-init/web.yaml` installs and configures nginx, including `/health` endpoint
- **Policies**: Three Azure Policy assignments for governance (location/SKU restrictions)

---

## Running the Terraform code

### 1. Clone the repository

```bash
git clone https://github.com/ektealexander/terraform.git
cd terraform/ak2
```

### 2. Prerequisites

- **Terraform** installed
- **Azure CLI** installed and signed in: `az login --tenant <tenant-id>`
- **Azure subscription** available for RG, network, LB, VMSS, and Policy resources

Confirm you are signed in and using the intended subscription:

```bash
az account show
```

### 3. Configure variables

Set values in `terraform.tfvars` based on `variables.tf`.

Important:

- `subscription_id` and `admin_password` are sensitive values
- Do not share these in recordings or screenshots
- Do not commit secrets

### 4. Init, plan, and apply

From the `ak2` folder (where `main.tf` lives):

```bash
terraform init
terraform plan
terraform apply
```

- `init` downloads providers and initializes modules
- `plan` shows changes without applying them
- `apply` creates the resource group, policies, network, load balancer, and VMSS

### 5. Get Load Balancer public IP

After a successful apply:

```bash
terraform output load_balancer_public_ip
```

Open `http://<ip>` in a browser.

---

## AK2 modules

| Path | Purpose |
|------|---------|
| `modules/rg/` | Creates the Resource Group |
| `modules/policies/` | Creates policy assignments |
| `modules/network/` | Creates VNet, subnet, and NSG |
| `modules/lb/` | Creates Public IP and Standard Load Balancer |
| `modules/vmss/` | Creates Linux VM Scale Set and connects subnet/LB |

### Where to change what

| Goal | File |
|------|------|
| Subscription, region, RG name, VM size, instance count, admin user/password | `terraform.tfvars` and `variables.tf` |
| VNet/subnet names and CIDR | `terraform.tfvars` |
| Policy values (allowed locations / VM SKUs) | `terraform.tfvars` |
| Nginx, health endpoint, and page content | `cloud-init/web.yaml` |
| NSG rules | `modules/network/main.tf` |
| LB frontend/backend/probe/rule | `modules/lb/main.tf` |
| VMSS image/sku/network/cloud-init wiring | `modules/vmss/main.tf` |

### Outputs

Defined in root `outputs.tf`:

- `resource_group_name`
- `load_balancer_public_ip`

---

## Verifying deployment

After `terraform apply`, verify:

| Check | Command / action | What you want to see |
|-------|------------------|----------------------|
| LB public IP exists | `terraform output load_balancer_public_ip` | An IP value |
| Web app is reachable | Open `http://<ip>` | Web page responds |
| Health endpoint works | Open `http://<ip>/health` | Healthy response |
| Terraform state is clean | `terraform plan` | `No changes` |

If web is unavailable, check that VMSS instances are running, LB probe `/health` is healthy, and cloud-init completed.

---

## Cleanup

Removes all resources Terraform created:

```bash
terraform destroy
```
