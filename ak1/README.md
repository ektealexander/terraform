# ST - Arbeidskrav 1

## Architecture

- **VM1**: Public IP, SSH from the internet, subnet `192.168.1.0/24`
- **VM2**: Private IP only `192.168.2.4`, subnet `192.168.2.0/24`
- **NSG**: One NSG per VM – VM1 allows SSH from the internet; VM2 allows SSH only from `192.168.1.0/24`

---

## Running the Terraform code

### 1. Clone the repository

```bash
git clone https://github.com/ektealexander/terraform.git
cd terraform/ak1
```

### 2. Prerequisites

- **Terraform** installed
- **Azure CLI** – installed and signed in: `az login --tenant <tenant-id>`
- **Azure subscription** – set in `main.tf` under `provider "azurerm"` (`subscription_id`)

Confirm you are signed in and using the intended subscription:

```bash
az account show
```

### 3. Init, plan, and apply

From the `ak1` folder (where `main.tf` lives):

```bash
terraform init
terraform plan
terraform apply
```

- `init` downloads the provider (azurerm) and initializes the working directory
- `plan` shows changes without applying them
- `apply` creates the resources (resource group, VNet, subnets, NSGs, NICs, VM1 and VM2)

### 4. Get VM1’s public IP

After a successful apply:

```bash
terraform output vm1_public_ip
```

---

## Ansible from VM1

1. **SSH to VM1**:

   ```bash
   ssh alespiadm@<vm1_public_ip>
   ```

   Password: `Password123`

2. **Install Ansible and sshpass** on VM1:

   ```bash
   sudo apt update && sudo apt install -y ansible sshpass
   ```

3. **Copy `ak1/ansible` to VM1**.

4. **On VM1, run the playbook**:

   ```bash
   cd ~/ansible
   ansible-playbook playbooks/playbook.yml
   ```

### Ansible files

| File / folder | Purpose |
|---------------|---------|
| `playbooks/playbook.yml` | Configures VM2 |
| `hosts` | Inventory: VM2 with `ansible_host=192.168.2.4` |
| `ansible.cfg` | Sets `inventory = ./hosts` |

The playbook creates the group `kulefolk`, adds users, and installs **nginx** on VM2.

### Verifying Ansible on VM2

From **VM1**, SSH to VM2 (same admin user and password as in `main.tf`):

```bash
ssh alespiadm@192.168.2.4
```

Then run:

| Check | Command | What you want to see |
|--------|---------|----------------------|
| Group exists | `getent group kulefolk` | A line starting with `kulefolk:` and listing member users |
| Users in the group | `id silje` and `id martin` | `groups=` includes `kulefolk` |
| nginx running | `sudo systemctl status nginx` | `running` |

---

## Cleanup

Removes all resources Terraform created:

```bash
terraform destroy
```
