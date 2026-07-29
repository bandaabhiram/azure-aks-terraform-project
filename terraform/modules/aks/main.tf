resource "azurerm_kubernetes_cluster" "this" {
name                = "${var.name_prefix}-aks"
location            = var.location
resource_group_name = var.resource_group_name
dns_prefix          = "${var.name_prefix}-aks"
kubernetes_version  = var.kubernetes_version

default_node_pool {
name           = "system"
node_count     = var.node_count
vm_size        = var.node_vm_size
vnet_subnet_id = var.subnet_id
}

identity {
type = "SystemAssigned"
}

network_profile {
network_plugin = "azure"
network_policy = "azure"
}

oms_agent {
log_analytics_workspace_id = var.log_analytics_id
}

tags = var.tags
}

# Allow the AKS cluster's managed identity to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
scope                = var.acr_id
role_definition_name = "AcrPull"
principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
