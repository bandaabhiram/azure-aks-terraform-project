# Azure AKS Infrastructure Provisioning with Terraform

A production-style, Infrastructure-as-Code project that provisions a complete Azure Kubernetes Service (AKS) environment using Terraform, deploys a containerized sample app to it, and wires up monitoring — end to end, no AWS involved.

This project is inspired by the "Terraform + Azure" project bucket from Vishakha Sadhwani's [5 Resume Projects for Cloud & DevOps Jobs](https://www.youtube.com/watch?v=X6Kw2_wZr1E) video, rebuilt from scratch as a standalone, runnable repo.

## Why this project

Recruiters look for candidates who can show real Infrastructure-as-Code and container-orchestration experience, not just theory. This repo demonstrates:

- Writing modular, reusable Terraform for a cloud provider (Azure)
- Provisioning a Kubernetes cluster (AKS) with networking, container registry, and observability
- Containerizing and deploying a real application to that cluster
- Validating infrastructure changes automatically via CI (GitHub Actions)

## Architecture

```
Resource Group
  |- Virtual Network
  |    |- AKS Subnet + Network Security Group
  |- Azure Container Registry
  |- Log Analytics Workspace
  |- AKS Cluster
       |- Sample App Pods --> LoadBalancer Service
```

## Tech stack

| Layer | Tool |
|---|---|
| Cloud provider | Microsoft Azure |
| Infrastructure as Code | Terraform (`azurerm` provider) |
| Container orchestration | Azure Kubernetes Service (AKS) |
| Container registry | Azure Container Registry (ACR) |
| Monitoring/logging | Azure Monitor + Log Analytics |
| App | Python / Flask (containerized with Docker) |
| CI | GitHub Actions (`terraform fmt`, `init`, `validate`) |

## Repository structure

```
azure-aks-terraform-project/
|-- terraform/
|   |-- main.tf                 # Root module wiring everything together
|   |-- variables.tf
|   |-- outputs.tf
|   |-- providers.tf
|   |-- environments/
|   |   |-- dev.tfvars.example
|   |-- modules/
|       |-- network/            # VNet, subnet, NSG
|       |-- acr/                 # Azure Container Registry
|       |-- aks/                 # AKS cluster + ACR pull role assignment
|       |-- monitoring/          # Log Analytics workspace + action group
|-- app/                        # Sample Flask app + Dockerfile
|-- k8s-manifests/               # Deployment, Service, Ingress
|-- .github/workflows/
|   |-- terraform-ci.yml         # fmt/init/validate on every PR
|-- .gitignore
```

## Prerequisites

- An Azure subscription ([free tier](https://azure.microsoft.com/free/) works)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), logged in via `az login`
- `kubectl`
- Docker (to build the sample app image)

## Getting started

**1. Authenticate to Azure**

```bash
az login
```

**2. Provision the infrastructure**

```bash
cd terraform
cp environments/dev.tfvars.example environments/dev.tfvars
terraform init
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars
```

**3. Connect to the cluster**

```bash
az aks get-credentials --resource-group <resource_group_name> --name <aks_cluster_name>
```

Both values are printed as Terraform outputs.

**4. Build and push the sample app to ACR**

```bash
az acr build --registry <acr_login_server> --image aks-demo-app:latest ./app
```

**5. Deploy the app to AKS**

Replace `<ACR_LOGIN_SERVER>` in `k8s-manifests/deployment.yaml` first, then:

```bash
kubectl apply -f k8s-manifests/
kubectl get svc aks-demo-app-svc
```

**6. Tear down** (avoid ongoing Azure costs)

```bash
terraform destroy -var-file=environments/dev.tfvars
```

## What each module does

- **network** — creates a VNet, a dedicated AKS subnet, and a Network Security Group attached to that subnet.
- **acr** — creates an Azure Container Registry with a randomized, globally-unique name.
- **monitoring** — creates a Log Analytics workspace (wired into the AKS cluster's `oms_agent`) and a Monitor action group for alerting.
- **aks** — creates the AKS cluster itself (system-assigned managed identity, Azure CNI networking) and grants the cluster's kubelet identity `AcrPull` on the registry so nodes can pull private images without embedding credentials.

## Estimated build time

4–8 hours for someone comfortable with basic Terraform syntax; a full day if you're learning Terraform and AKS concepts as you go.

## Common issues

- **ACR name already taken** — registry names must be globally unique across Azure; the module appends a random suffix to reduce collisions.
- **Insufficient quota for VM size** — some subscriptions (especially free tier) don't have quota for certain VM sizes/regions; try `Standard_B2s` in `eastus` or `westus2` first.
- **`terraform destroy` hangs deleting AKS** — this is normal, AKS deletion can take 5-10 minutes.

## Resume bullet you can use

> Provisioned a modular, multi-tier Azure infrastructure (VNet, AKS, ACR, Log Analytics) using Terraform, deployed a containerized application to Kubernetes, and added a CI pipeline to validate infrastructure changes on every pull request.

## Credit

Project idea inspired by Vishakha Sadhwani's ["5 Resume Projects for Cloud & DevOps Jobs"](https://www.youtube.com/watch?v=X6Kw2_wZr1E) — specifically the Terraform-on-Azure track, based on [piyushsachdeva/Terraform-Full-Course-Azure](https://github.com/piyushsachdeva/Terraform-Full-Course-Azure). All Terraform, application, and Kubernetes code in this repo was written independently.
