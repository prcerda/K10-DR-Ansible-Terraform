# Terraform K10AKS

***Status:** Work-in-progress. Please create issues or pull requests if you have ideas for improvement.*

# **Fully automated deploy of Azure AKS Cluster with Kasten**
Example of using Terraform to automate the deploy of an Azure AKS cluster, plus the installation and initial Kasten K10 configuration 


## Summary
This projects demostrates the process of deploying an Azure AKS cluster, plus installing and configurig Kasten K10 using Terraform for fully automation of this process.  The resources to be created include:
* VNET Resources
* AKS Cluster
    - Volume Snapshot Class
* Azure Blob
* Kasten
    - Token Authentication
    - Access via LoadBalancer
    - EULA agreement
    - Location Profile creation using Azure Blob
    - Policy preset samples creation
* Demo App
* All components with Azure tags

**NOTE**: The Demo App has been build by [Timothy Dewin](https://github.com/tdewin/stock-demo/tree/main/kubernetes)

All the automation is done using Terraform and leveraging the Azure, Kubernetes, and [Kasten K10](https://docs.kasten.io/latest/api/cli.html) APIs.

## Disclaimer
This project is an example of an deployment and meant to be used for testing and learning purposes only. Do not use in production. 


# Table of Contents

1. [Prerequisites](#Prerequisites)
2. [Installing AKS Cluster and Kasten](#Installing-AKS-Cluster-and-Kasten)
3. [Using the Azure AKS cluster and Kasten](#Using-the-Azure-AKS-cluster-and-Kasten)
4. [Destroying the AKS Cluster](#Destroying-the-AKS-Cluster)



## Prerequisites
To run this project you need to have some software installed and configured: 
1. [Terraform](https://developer.hashicorp.com/terraform/tutorials/Azure-get-started/install-cli)
Ej. using brew for macOS

```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

2. [Helm](https://helm.sh/docs/intro/install/)
Ej. using brew for macOS

```
brew install helm
```

3. [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
Ej. using brew for macOS

```
brew install kubectl
```

4. [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
Ej. using brew for macOS
```
brew install azure-cli
```

5. Configure Azure CLI providing credentials with enough privileges to create resources in Azure.
```
az login 
```

6. Download all terraform files and keep them locally, all in the same folder in your laptop :



## Installing AKS Cluster and Kasten
For Terraform to work, we need to provide certain information to be used as variables in the **terraform.tfvars** file.   

| Name                    | Type     | Default value       | Description                                                    |
| ----------------------- | -------- | ------------------- | -------------------------------------------------------------- |
| `location`              | String   | `westeurope`        | Azure Region where all resources will be created                 |
| `cluster_name `         | String   | `k10`               | Name of the cluster to be created.  All Azure resources will use the same name  |
| `aks_instance_type`     | String   | `Standard_DS2_v2`   | Specify the AKS nodes instance type  |
| `aks_num_nodes`         | Number   | `3`                 | Number of AKS Worker nodes to be created  |
| `vnet_cidr_block_ipv4`  | String   | `10.50.0.0/16`      | CIDR block for the new VNET where the AKS cluster will be deployed  |
| `subnet_cidr_block_ipv4`| String   | `10.50.1.0/24`      | CIDR block for the subnet inside the VNET where the AKS cluster will be deployed  |
| `owner`                 | String   | `owner@domain.com`  | Owner tag in Azure            |
| `activity`              | String   | `demo`              | Activity tag in Azure         |

### Building the AKS Cluster with Kasten
Once the variables are set, the only thing we need to do is to apply the Terraform files:
- By using a terminal, go to the folder containing all terraform files.
- Run the following commands
```
terraform init
terraform apply
```


## Using the Azure AKS cluster and Kasten
Once Terraform is done building the infrastructure and installing Kasten, you will get the following information:

| Name                      | Value       | Description                                                    |
| ------------------------- | ----------- | -------------------------------------------------------------- |
| `kubernetes_cluster_name` | `aks-k10-1719319697`         | Name of the Azure AKS cluster created, with a random number to prevent conflicts               |
| `demoapp_url`             | `http://108.141.191.243`              | URL to access the demo Stock app        |
| `k10url `                 | `http://108.141.189.141/k10/`    | URL to access the Kasten K10 Dashboard  |
| `k10token`                | `eyJhbGciOiJSUzI1NiIsImtpZCI6IjVjODIyNTU`  | Token to be used for Kasten authentication |
| `az_bucket_name`          | `blobk101719250214`              | Azure Blob to be used as Location profile         |
| `kubeconfig`              | `az aks get-credentials --resource-group rg-k10-1719319697 --name aks-k10-1719319697` | Command to configure the kubeconfig file and access the kubernetes cluster with kubectl  |


At this point, it's possible to run tests to backup and restore the demo App, creating policies and as an option it's also possible to use Kanister for consistent backups of the PostgreSQL database.


## Destroying the AKS Cluster
Once you are done using the AKS cluster, you can destroy it alonside all other resources created with Terraform, by using the following command:
```
terraform destroy
```
