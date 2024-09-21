## Kasten namespace
resource "kubernetes_namespace" "kastenio" {
  depends_on = [azurerm_kubernetes_cluster.aks-cluster]
  metadata {
    name = "kasten-io"
  }
}

## Kasten Helm
resource "helm_release" "k10" {
  depends_on = [azurerm_kubernetes_cluster.aks-cluster,helm_release.az-volumesnapclass]  
  name = "k10"
  namespace = kubernetes_namespace.kastenio.metadata.0.name
  repository = "https://charts.kasten.io/"
  chart      = "k10"
  
  set {
    name  = "externalGateway.create"
    value = true
  }

  set {
    name  = "azure.useDefaultMSI"
    value = true
  } 

  set {
    name  = "auth.tokenAuth.enabled"
    value = true
  } 
}

##  Creating authentication Token
resource "kubernetes_token_request_v1" "k10token" {
  depends_on = [helm_release.k10]

  metadata {
    name = "k10-k10"
    namespace = kubernetes_namespace.kastenio.metadata.0.name
  }
  spec {
    expiration_seconds = var.tokenexpirehours*3600
  }
}

## Getting Kasten LB Address
data "kubernetes_service_v1" "gateway-ext" {
  depends_on = [helm_release.k10]
  metadata {
    name = "gateway-ext"
    namespace = "kasten-io"
  }
}

## Accepting EULA
resource "kubernetes_config_map" "eula" {
  depends_on = [helm_release.k10]
  metadata {
    name = "k10-eula-info"
    namespace = "kasten-io"
  }
  data = {
    accepted = "true"
    company  = "Veeam"
    email = var.owner
  }
}


## Kasten Azure Blob Location Profile
resource "helm_release" "az-blob-locprofile" {
  depends_on = [helm_release.k10]
  name = "${var.cluster_name}-az-blob-locprofile"
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "az-blob-locprofile"  
  
  set {
    name  = "K10Location.bucketname"
    value = azurerm_storage_account.repository.name
  }
  set {
    name  = "K10Location.azure_storage_env"
    value = "AzureCloud"
  }
  set {
    name  = "K10Location.azure_storage_key"
    value = azurerm_storage_account.repository.primary_access_key
  }  
}

## Kasten K10 Config
resource "helm_release" "k10-config" {
  depends_on = [helm_release.k10]
  name = "${var.cluster_name}-k10-config"
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "k10-config"  
  
  set {
    name  = "bucketname"
    value = azurerm_storage_account.repository.name
  }

  set {
    name  = "buckettype"
    value = "azblob"
  }
}
