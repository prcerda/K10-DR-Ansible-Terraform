location            = "westeurope"
cluster_name        = "k10"

# Specify the appliance instance type.
# For the list of supported instance types, review the veeam_aws_instance_type variable in the variables.tf file.
# Default is Standard_B2s.
aks_instance_type = "Standard_DS2_v2"
aks_num_nodes = 3

# CIDR block for the new VNET where the appliance will be deployed.
vnet_cidr_block_ipv4 = "10.50.0.0/16"

# CIDR block for the subnet inside the VNET where the appliance will be deployed.
subnet_cidr_block_ipv4 = "10.50.1.0/24"

#labels
owner = "owner@domain.com"
activity = "demo"


