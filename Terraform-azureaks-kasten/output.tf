output "vnet_name" {
  description = "VNET Name"
  value = azurerm_virtual_network.vnet_network.name
}

output "subnet_name" {
  description = "Subnet Name"
  value = azurerm_subnet.subnet-k10-demo.name
}

output "az_bucket_name" {
  description = "Azure Storage Account name"
  value = azurerm_storage_account.repository.name
}


output "resource_group_name" {
  value = azurerm_resource_group.demo_rgroup.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks-cluster.name
}

output "kubeconfig" {
  description = "Configure kubeconfig to access this cluster"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.demo_rgroup.name} --name ${azurerm_kubernetes_cluster.aks-cluster.name}"
}

output "k10token" {
  value = nonsensitive(kubernetes_token_request_v1.k10token.token)
}

output "k10url" {
  description = "Kasten K10 URL"
  value = "http://${data.kubernetes_service_v1.gateway-ext.status.0.load_balancer.0.ingress.0.ip}/k10/"
}