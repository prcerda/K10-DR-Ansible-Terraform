resource "time_static" "epoch" {}
locals {
  saString = "${time_static.epoch.unix}"
}

locals {
  cluster_int_name = "aks-${var.cluster_name}-${local.saString}"
}

# Create a resource group
resource "azurerm_resource_group" "demo_rgroup" {
  name     = "rg-${var.cluster_name}-${local.saString}"
  location = var.location
  tags = {
    owner = var.owner
    activity = var.activity
  }    
}

# VNET Network
resource "azurerm_virtual_network" "vnet_network" {
  name                = "vnet-${var.cluster_name}-${local.saString}"
  address_space       = ["10.50.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.demo_rgroup.name
  tags = {
    owner = var.owner
    activity = var.activity
  }       
}


#Subnet
resource "azurerm_subnet" "subnet-k10-demo" {
  name                 = "subnet-${var.cluster_name}-${local.saString}"
  resource_group_name  = azurerm_resource_group.demo_rgroup.name
  virtual_network_name = azurerm_virtual_network.vnet_network.name
  address_prefixes       = ["10.50.1.0/24"]
}

# Create storage account 
resource "azurerm_storage_account" "repository" {
  name                        = "blob${var.cluster_name}${local.saString}"
  resource_group_name         = azurerm_resource_group.demo_rgroup.name
  location                    = var.location
  account_tier                = "Standard"
  account_replication_type    = "LRS"
  tags = {
    owner = var.owner
    activity = var.activity
  }        
}

resource "azurerm_storage_container" "container" {
  name                  = "k10"
  storage_account_name  = azurerm_storage_account.repository.name
  container_access_type = "private"
}

## Private Link

# Create User Assigned Identity
resource "azurerm_user_assigned_identity" "aks-demo-id" {
  location            = azurerm_resource_group.demo_rgroup.location
  name                = "aks-id-${var.cluster_name}-${local.saString}"
  resource_group_name = azurerm_resource_group.demo_rgroup.name
  tags = {
    owner = var.owner
    activity = var.activity
  } 
}

## Create AKS Cluster

resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = "aks-${var.cluster_name}-${local.saString}"
  location            = azurerm_resource_group.demo_rgroup.location
  resource_group_name = azurerm_resource_group.demo_rgroup.name
  dns_prefix          = "dns-${var.cluster_name}-${local.saString}"

  default_node_pool {
      name            = "default"
      node_count      = var.aks_num_nodes
      vm_size         = "${var.aks_instance_type}"
      os_disk_size_gb = 30
  }

  identity {
      type = "SystemAssigned"
  }
  tags = {
    owner = var.owner
    activity = var.activity
  }     
}


## AKS Disk VolumeSnapshotClass
resource "helm_release" "az-volumesnapclass" {
  depends_on = [azurerm_kubernetes_cluster.aks-cluster]
  name = "az-volumesnapclass"
  create_namespace = true

  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "az-volumesnapclass"  
}
