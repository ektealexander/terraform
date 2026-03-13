# Arbeidskrav 1 – Terraform

## Arkitektur

- **VM1**: Offentlig IP, SSH fra internett, subnet `192.168.1.0/24`
- **VM2**: Kun privat IP `192.168.2.4`, subnet `192.168.2.0/24`
- **NSG**: En NSG per VM – VM1 tillater SSH fra internett; VM2 tillater kun SSH fra `192.168.1.0/24`

---

## Slik kjøres Terraform-koden

### 1. Last ned koden fra GitHub

```bash
git clone https://github.com/ektealexander/terraform.git
cd terraform/ak1
```

### 2. Forutsetninger

- **Terraform**
- **Azure CLI** – installert og innlogget: `az login --tenant <tenant-id>`
- **Azure-abonnement** – satt i `main.tf` under `provider "azurerm"` (`subscription_id`)

Sjekk at du er innlogget og har riktig abonnement:

```bash
az account show
```

### 3. Init, plan og apply

Fra mappen `ak1` (der `main.tf` ligger):

```bash
terraform init
terraform plan
terraform apply
```

- `init` henter provider (azurerm) og initialiserer backend
- `plan` viser endringer uten å gjøre dem
- `apply` oppretter ressursene (resource group, vnet, subnets, NSGer, NIC-er, VM1 og VM2)

### 4. Hent VM1 sin offentlige IP

Etter vellykket apply:

```bash
terraform output vm1_public_ip
```
---

## Ansible fra VM1

1. **SSH til VM1**:
   ```bash
   ssh alespiadm@<vm1_public_ip>
   ```
   Passord: `Password123`

2. **Installer Ansible og sshpass** på VM1:
   ```bash
   sudo apt update && sudo apt install -y ansible sshpass
   ```

3. **Kopier `ak1/ansible` til VM1**.

4. **På VM1, kjør playbook**:
   ```bash
   cd ~/ansible
   ansible-playbook playbooks/playbook.yml
   ```

### Ansible-filer

| Fil / mappe | Hensikt |
|-------------|--------|
| `playbooks/playbook.yml` | Konfigurerer VM2 |
| `hosts` | Inventory: VM2 med `ansible_host=192.168.2.4` |
| `ansible.cfg` | Setter `inventory = ./hosts` |

Playbooken oppretter gruppen `kulefolk`, brukere og installerer `htop` på VM2

---

### Rydde opp

Fjerner alle ressursene som Terraform har opprettet:

```bash
terraform destroy
```
