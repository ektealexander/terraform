# Arbeidskrav 1 – Terraform + Ansible

ST – Azure: to Linux-VM'er i Azure (Terraform), der VM1 er Ansible-controller og VM2 konfigureres med Ansible.

## Oppsett

- **VM1** (ansible-controller): Offentlig IP, SSH fra internett, subnet `192.168.1.0/24`. Ansible installeres manuelt på VM1.
- **VM2**: Kun privat IP `192.168.2.4`, subnet `192.168.2.0/24`. Nås bare fra VM1.
- **NSG**: Det brukes én NSG per VM (anbefalt for tydelige regler): VM1-nsg tillater SSH (22) fra internett; VM2-nsg tillater kun SSH fra `192.168.1.0/24` (kun VM1). Oppgaven krever «minst 1 NSG mellom VM'ene» – det er oppfylt.

Ingen custom_data/cloud-init – alt gjøres manuelt på VM1.

## Forutsetninger

- Azure CLI installert og innlogget (`az login`)
- Terraform installert
- Abonnement satt i `main.tf` (eller via miljøvariabler)

## Kjør Terraform

```bash
cd ak1
terraform init
terraform plan
terraform apply
```

Etter apply – hent VM1 sin offentlige IP:

```bash
terraform output vm1_public_ip
```

**VM1-IP uten output i main.tf:** Du kan alltid hente IP fra Terraform state eller Azure CLI:
- `terraform state show azurerm_public_ip.vm1` (se hele ressursen, inkl. `ip_address`)
- Azure CLI: `az network public-ip show -g terraform -n vm1-public-ip --query ipAddress -o tsv`

## Ansible fra VM1 (manuelt)

1. **SSH til VM1** (fra din PC):
   ```bash
   ssh alespiadm@<vm1_public_ip>
   ```
   Passord: `Password123`

2. **Installer Ansible og sshpass** på VM1:
   ```bash
   sudo apt update && sudo apt install -y ansible sshpass
   ```

3. **Kopier `ak1/ansible` til VM1** (fra din PC, i en annen terminal, stå i repo-roten):
   ```bash
   scp -r ak1/ansible alespiadm@<vm1_public_ip>:~/
   ```

4. **På VM1, kjør playbook** (første gang: skriv `yes` ved spørsmål om VM2 sin host-nøkkel):
   ```bash
   cd ~/ansible
   ansible-playbook playbooks/playbook.yml
   ```
   (Inventory er satt i `ansible.cfg` til `./hosts`.)

### Innhold i `ak1/ansible/`

| Fil / mappe | Hensikt |
|-------------|--------|
| `playbooks/playbook.yml` | Playbook som konfigurerer VM2 (gruppe, brukere, pakke). |
| `hosts` | Inventory: VM2 med `ansible_host=192.168.2.4`, bruker og passord. |
| `ansible.cfg` | Setter `inventory = ./hosts` så du ikke trenger `-i` ved kjøring. |

### Hva playbooken gjør på VM2

- Oppretter gruppen `kulefolk`
- Oppretter brukerne `silje` og `martin` (med gruppe `appusers` – endre til `kulefolk` i playbook for konsistens om du vil)
- Installerer `htop`

Du kan bytte gruppe/brukernavn eller program (f.eks. `nginx`, `tree`) i `ansible/playbooks/playbook.yml` og kjøre playbook på nytt.
