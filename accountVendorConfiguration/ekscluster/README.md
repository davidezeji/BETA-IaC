# Deployment Execution Setting

This code will configure the necessary EKS infrastructure for each account that has the value **"ekscluster": true** in *aws_accounts.json*. If the ISV does not need an EKS Cluster make sure **"ekscluster": false** is set.

## Terraform Modules

Terraform will deploy AWS Resources using the following Modules:

- label
- ekscluster
- multus-lambda
- eksnodes

## Terraform Parameters

Terraform will pull in locals values from *aws_accounts.json* and populate values for each resource. Those values include:

- clustername
- vpc_id
- vpc_cidr
- private_app_subnets (Value created in JSON by vendorTrim.py execution)
- ekscluster_version
- multus_subnets (Value created in JSON by vendorTrim.py execution)
- eks_node_type
- eks_node_desired
- eks_node_min
- eks_node_max
- eks_node_disksize

## vendorTrim.py

This file uses the local $ACCOUNT value to select only what's needed from aws_accounts.json and create a new file *specific_vendor.json*. The new file only contains relevant ISV resources. This makes the Terraform locals process easier to read and understand. Additionally this function will create new key value pairs: multus_subnets and private_app_subnets. These join existing subnet ids that match the values, again this was done to get around Terraform limitations with locals.
