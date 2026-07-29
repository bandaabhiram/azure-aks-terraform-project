# Azure AKS Infrastructure Provisioning with Terraform

A production-style Infrastructure-as-Code project that provisions a complete Azure Kubernetes Service (AKS) environment using Terraform, deploys a containerized sample app to it, and wires up monitoring — end to end, no AWS involved.

## What this is

- A modular Terraform setup (network, ACR, AKS, monitoring) that provisions a real AKS cluster on Azure
- A small containerized Flask app deployed onto that cluster via Kubernetes manifests
- A GitHub Actions workflow that validates every Terraform change on PR

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

- **network** — VNet, a dedicated AKS subnet, and a Network Security Group attached to it.
- **acr** — Azure Container Registry with a randomized, globally-unique name.
- **monitoring** — Log Analytics workspace (wired into the AKS cluster's `oms_agent`) and a Monitor action group for alerting.
- **aks** — the AKS cluster itself (system-assigned managed identity, Azure CNI networking), with an `AcrPull` role assignment so nodes can pull private images without embedding credentials.

## Notes / gotchas

- **ACR name already taken** — registry names must be globally unique across Azure; the module appends a random suffix to reduce collisions.
- **Insufficient quota for VM size** — some subscriptions (especially free tier) don't have quota for certain VM sizes/regions; try `Standard_B2s` in `eastus` or `westus2` first.
- **`terraform destroy` hangs deleting AKS** — normal, AKS deletion can take 5-10 minutes.

## License

MIT
