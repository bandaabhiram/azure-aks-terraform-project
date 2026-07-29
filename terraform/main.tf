locals {
name_prefix = "${var.project_name}-${var.environment}"
tags        = merge(var.tags, { environment = var.environment })
}

resource "azurerm_resource_group" "this" {
name     = "${local.name_prefix}-rg"
location = var.location
tags     = local.tags
}

module "network" {
source = "./modules/network"

name_prefix         = local.name_prefix
resource_group_name = azurerm_resource_group.this.name
location            = azurerm_resource_group.this.location
vnet_address_space  = var.vnet_address_space
aks_subnet_prefix   = var.aks_subnet_prefix
tags                = local.tags
}

module "acr" {
source = "./modules/acr"

name_prefix         = local.name_prefix
resource_group_name = azurerm_resource_group.this.name
location            = azurerm_resource_group.this.location
tags                = local.tags
}

module "monitoring" {
source = "./modules/monitoring"

name_prefix         = local.name_prefix
resource_group_name = azurerm_resource_group.this.name
location            = azurerm_resource_group.this.location
tags                = local.tags
}

module "aks" {
source = "./modules/aks"

name_prefix          = local.name_prefix
resource_group_name  = azurerm_resource_group.this.name
location             = azurerm_resource_group.this.location
subnet_id            = module.network.aks_subnet_id
node_count           = var.node_count
node_vm_size         = var.node_vm_size
kubernetes_version   = var.kubernetes_version
acr_id               = module.acr.acr_id
log_analytics_id     = module.monitoring.log_analytics_workspace_id
tags                 = local.tags
}
