# Azure AKS Infrastructure Provisioning with Terraform

A production-style, Infrastructure-as-Code project that provisions a complete Azure Kubernetes Service (AKS) environment using Terraform, deploys a containerized sample app to it, and wires up monitoring - end to end, no AWS involved.

This project is inspired by the "Terraform + Azure" project bucket from Vishakha Sadhwani's 5 Resume Projects for Cloud & DevOps Jobs video (https://www.youtube.com/watch?v=X6Kw2_wZr1E), rebuilt from scratch as a standalone, runnable repo.

## Why this project

Recruiters look for candidates who can show real Infrastructure-as-Code and container-orchestration experience, not just theory. This repo demonstrates:

- Writing modular, reusable Terraform for a cloud provider (Azure)
- - Provisioning a Kubernetes cluster (AKS) with networking, container registry, and observability
  - - Containerizing and deploying a real application to that cluster
    - - Validating infrastructure changes automatically via CI (GitHub Actions)
     
      - ## Architecture
     
      - Resource Group containing: Virtual Network with an AKS subnet and NSG, an Azure Container Registry, a Log Analytics Workspace, and the AKS Cluster itself running the sample app pods behind a LoadBalancer service.
     
      - ## Tech stack
     
      - - Cloud provider: Microsoft Azure
        - - Infrastructure as Code: Terraform (azurerm provider)
          - - Container orchestration: Azure Kubernetes Service (AKS)
            - - Container registry: Azure Container Registry (ACR)
              - - Monitoring/logging: Azure Monitor + Log Analytics
                - - App: Python / Flask (containerized with Docker)
                  - - CI: GitHub Actions (terraform fmt, init, validate)
                   
                    - ## Repository structure
                   
                    - - terraform/ - main.tf, variables.tf, outputs.tf, providers.tf, environments/dev.tfvars.example, and modules/ (network, acr, aks, monitoring)
                      - - app/ - sample Flask app + Dockerfile
                        - - k8s-manifests/ - Deployment, Service, Ingress
                          - - .github/workflows/terraform-ci.yml - fmt/init/validate on every PR
                           
                            - ## Prerequisites
                           
                            - - An Azure subscription (free tier works)
                              - - Terraform >= 1.6
                                - - Azure CLI, logged in via az login
                                  - - kubectl
                                    - - Docker (to build the sample app image)
                                     
                                      - ## Getting started
                                     
                                      - 1. Authenticate to Azure
                                        2.    az login
                                       
                                        3.2. Provision the infrastructure
                                           cd terraform
                                           cp environments/dev.tfvars.example environments/dev.tfvars
                                           terraform init
                                           terraform plan -var-file=environments/dev.tfvars
                                           terraform apply -var-file=environments/dev.tfvars

                                        3. Connect to the cluster
                                        4.    az aks get-credentials --resource-group <resource_group_name> --name <aks_cluster_name>
                                           (Both values are printed as Terraform outputs.)

                                          4. Build and push the sample app to ACR
                                          5.    az acr build --registry <acr_login_server> --image aks-demo-app:latest ./app
                                       
                                          6.5. Deploy the app to AKS
                                           (replace <ACR_LOGIN_SERVER> in k8s-manifests/deployment.yaml first)
                                           kubectl apply -f k8s-manifests/
                                           kubectl get svc aks-demo-app-svc

                                        6. Tear down (avoid ongoing Azure costs)
                                        7.    terraform destroy -var-file=environments/dev.tfvars
                                       
                                        8.## What each module does

                                        - network - creates a VNet, a dedicated AKS subnet, and a Network Security Group attached to that subnet.
                                        - - acr - creates an Azure Container Registry with a randomized, globally-unique name.
                                          - - monitoring - creates a Log Analytics workspace (wired into the AKS cluster's oms_agent) and a Monitor action group for alerting.
                                            - - aks - creates the AKS cluster itself (system-assigned managed identity, Azure CNI networking) and grants the cluster's kubelet identity AcrPull on the registry so nodes can pull private images without embedding credentials.
                                             
                                              - ## Estimated build time
                                             
                                              - 4-8 hours for someone comfortable with basic Terraform syntax; a full day if you're learning Terraform and AKS concepts as you go.
                                             
                                              - ## Common issues
                                             
                                              - - ACR name already taken: registry names must be globally unique across Azure; the module appends a random suffix to reduce collisions.
                                                - - Insufficient quota for VM size: some subscriptions (especially free tier) don't have quota for certain VM sizes/regions - try Standard_B2s in eastus or westus2 first.
                                                  - - terraform destroy hangs deleting AKS: this is normal, AKS deletion can take 5-10 minutes.
                                                   
                                                    - ## Resume bullet you can use
                                                   
                                                    - Provisioned a modular, multi-tier Azure infrastructure (VNet, AKS, ACR, Log Analytics) using Terraform, deployed a containerized application to Kubernetes, and added a CI pipeline to validate infrastructure changes on every pull request.
                                                   
                                                    - ## Credit
                                                   
                                                    - Project idea inspired by Vishakha Sadhwani's "5 Resume Projects for Cloud & DevOps Jobs" (https://www.youtube.com/watch?v=X6Kw2_wZr1E) - specifically the Terraform-on-Azure track, based on piyushsachdeva/Terraform-Full-Course-Azure. All Terraform, application, and Kubernetes code in this repo was written independently.
                                                    - 
