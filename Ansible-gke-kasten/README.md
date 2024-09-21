***Status:** Work-in-progress. Please create issues or pull requests if you have ideas for improvement.*

# **Kasten K10 full automated Disaster Recovery with Ansible**
Example of using the Kasten K10 Disaster Recovery feature with Ansible to automate the Disaster Recovery Plan for Kubernetes workloads.

## Summary
This projects demostrates the process of recovering a Kasten K10 instance and all the protected Kubernetes workloads (applications) after a disaster ocurrs on Kubernetes cluster.  

All the automation is done using Ansible playbooks and leveraging the [Kasten K10 API](https://docs.kasten.io/latest/api/cli.html).

## Disclaimer
This project is an example of an deployment and meant to be used for testing and learning purposes only. Do not use in production. 


# Table of Contents

1. [Prerequisites](#Prerequisites)
1. [Variables](#Variables)
1. [Recovering Kasten configuration with Ansible](#Recovering-Kasten-configuration-with-Ansible)
1. [Recovering Application from Kasten backups with Ansible](#Recovering-Application-from-Kasten-backups-with-Ansible)

# Getting started

K10 Disaster Recovery (DR) aims to protect K10 from the underlying infrastructure failures. In particular, this feature provides the ability to recover the K10 platform in case of a variety of disasters such as the accidental deletion of K10, failure of underlying storage that K10 uses for its catalog, or even the accidental destruction of the Kubernetes cluster on which K10 is deployed.

K10 enables Disaster Recovery with the help of an internal policy to backup its own data stores and store these in an object storage bucket or an NFS file storage location configured using a Location Profile.

## Prerequisites
To run this project you need to have some software installed and configured: 
1. A workstation with the next tools installed:
	- Kubectl
	- Kubernetes Collection for Ansible
	- Helm
	- Kubeconfig file configured and kubectl context selected	
	- gcloud CLI and gke-gcloud-auth-plugin for use with kubectl
1. A working [Ansible installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
1. A working Kubernetes cluster.  You can deploy an [Google GKE (Google Kubernetes Engine) Cluster](./Terraform-gcgke-kasten/README.md) using Terraform.


## Variables
Some deployment variables must be set into the vars files.  Alter the parameters according to your needs:

[Ansible Vault](vars/k10gkedr_vars.yaml) "k10gkedr_vars.yaml" in the vars folder.
**NOTE**: It is recommended to use Ansible Vaults to keep this data instead of using just a text file, considering all the sensitive data to be kept here.

| Name                    | Type     | Default value          | Description                                                                                                            |
| ----------------------- | -------- | ---------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `region`        		  | `string` | `europe-west2`  		  | Bucket region                           										                                       |
| `profile_name`          | `string` | `test-bucket`          | Name of the Location Profile in Kasten	                                                                               |
| `bucket_name`           | `string` | `test-bucket`          | Name of the Google Cloud Storage Account to be used as Location Profile	                                                                               |
| `passphrase`            | `string` | `mysuperpassword`  	  | Passphrase used when enabling Kasten DR feature									                                       |
| `secret_name`           | `string` | `k10-gcs-secret`  	  | Name of the secret to be created with Google Clous Storage Account Key									                                       |
| `clusterid`             | `string` | `aaaaaaaaa-eeee-dddd-cccc-bbbbbbbbb`| Cluster ID can be got from K10 DR Settings             |
| `project_id`            | `string` | `gcloud-project-id`    | Google Project ID to add Google Cloud Storage Account                                                                  |



## Recovering Kasten configuration with Ansible
To recover Kasten Configuration we will be using the 01_k10_dr_restore.yaml Ansible Playbook.
	- This playbook creates the  Kubernetes Secret "k10-dr-secret" using the passphrase provided while enabling Disaster Recovery
	- Then, this playbook creates a Location Profile using the provided Object Storage, which of course MUST contain the Kasten configuration backup (this is the Location Profile used when enabling the Kasten K10 Disaster Recovery in the Production Kubernetes cluster).  
	- Finally this playbook restores the Kasten K10 configuration from the Location Profile created.

Run the following command:

ansible-playbook   01_k10_dr_restore.yaml

In case you are using Ansible Vaults for variables (recommended), please run the following command instead:
ansible-playbook   --ask-vault-pass 01_k10_dr_restore.yaml



## Recovering Application from Kasten backups with Ansible
To recover all protected applications from Kasten backups will be using the 02_k10_restoreapps.yaml Ansible Playbook.
	- This playbook look for the most recent restore points available to restore the cluster-wide resources and each application.
	- Then the playbook restore the cluster-wide resources from the most recent restore point found in previous step.
	- Next the playbook creates a namespace for every application to be restored.
	- Finally the playbook restore every application from the most recent restore point found in previous step.

Run the following command:

ansible-playbook   02_k10_restoreapps.yaml

In case you are using Ansible Vaults for variables (recommended), please run the following command instead:
ansible-playbook   --ask-vault-pass 02_k10_restoreapps.yaml

