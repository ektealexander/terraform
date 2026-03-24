## Cloud – Terraform

This repository is a collection of coursework and lab exercises for **cloud services**, with a focus on infrastructure as code (IaC) in the cloud (**Azure**) using **Terraform**.

The repo serves as a technical log of that work.

---

## Layout

Work is organized in subfolders—typically one folder per assignment or exercise. Each folder has its own README describing the contents and how to run the code.

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- Access to an Azure subscription and a way to authenticate the Azure provider (for example [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) with `az login`, or a service principal via environment variables)

Details vary by exercise; check each subfolder’s README.

---

## Getting started

1. **Clone the repository**

   ```bash
   git clone https://github.com/ektealexander/terraform.git
   cd terraform
   ```

2. **Open the folder** for the exercise you want and read its README.

3. **From that folder**, run Terraform as described there. A typical flow looks like:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

   Use `terraform destroy` when you want to tear down resources created by that configuration.
