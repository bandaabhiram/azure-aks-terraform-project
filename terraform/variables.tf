variable "project_name" {
description = "Short name used as a prefix for all resources"
type        = string
default     = "aks-demo"
}

variable "environment" {
description = "Deployment environment (dev, staging, prod)"
type        = string
default     = "dev"
}

variable "location" {
description = "Azure region to deploy resources into"
type        = string
default     = "eastus"
}

variable "vnet_address_space" {
description = "Address space for the virtual network"
type        = list(string)
default     = ["10.10.0.0/16"]
}

variable "aks_subnet_prefix" {
description = "Address prefix for the AKS node subnet"
type        = list(string)
default     = ["10.10.1.0/24"]
}

variable "node_count" {
description = "Number of nodes in the default AKS node pool"
type        = number
default     = 2
}

variable "node_vm_size" {
description = "VM size for AKS nodes"
type        = string
default     = "Standard_B2s"
}

variable "kubernetes_version" {
description = "Kubernetes version for the AKS cluster (leave null for latest supported)"
type        = string
default     = null
}

variable "tags" {
description = "Common tags applied to all resources"
type        = map(string)
default = {
project = "aks-resume-project"
managed_by = "terraform"
}
}
