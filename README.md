# Pipeline Definition

This Pipeline will create new AWS Accounts, configure desired Guardrails, and deploy EKS cluster resources dynamically using *aws_accounts.json* for inputs. Each key/value pair is used to set parameters for Terraform modules during each stage of the pipeline. This single file is passed as an artifact through each stage and is updated as resources are created. Appended values include: AWS Account numbers, VPC/Subnet IDs, Tagging, Resource Share IDs, EKS Cluster information, etc.

## Module use

Review the example folder for folder structure and design for apply the module in the root.
Modify aws_accounts.json to create additional accounts:

```{
  "accounts": {
      "<AccountType>": {
          "<IsvAccount>": {
              "account_email": "<UniqueEmail>",
              "ou_id": "<OuId>",
              "owner_email": "<IsvContact>",
              "ticket_number": "<TicketNumber>",
              "isvname": "<IsvAbbreviation>",
              "environment": "<EnvType>",
              "<Region>":{
                "vpc_cidr": "<VpcCidr>",
                "secondary_cidr": "<MultusCidr>",
                "ekscluster": <Boolean, true/false>,
                "clustertype": "<TypeOfCluster>",                
                "ekscluster_version": <VersionNumber>,
                "eks_node_desired": <Number; Desired Number of AutoScaling Instances>,
                "eks_node_min": <Number; Minimum Number of AutoScaling Instances>,
                "eks_node_max": <Number; Maximum Number of AutoScaling Instances>,
                "eks_node_type": "<InstanceType>",
                "eks_node_disksize": <SizeInGb>,
                "clustername": "<ClusterID/Name>",
                "s3_bucket": <Boolean, true/false>,
                "db_module": <Boolean, true/false>
              }
          }
      }
  }
}```

* account_type is used to keep certain environments together. (RDC, NDC, etc)
* IsvAccount is used to create new AWS Accounts
* account_email must be unique and is associated to the new IsvAccount AWS Account
* ou_id will place the new account into an existing OU
* owner_email, account_type, ticket_number are used for tagging

### Files and Functions

In addition to the descriptions below, additional documentation for each resource should be within the README files in each folder.

#### accountCreation (Folder)

This folder contains all the terraform code to create accounts, vpc, and ram sharing. All resources in this stage are created within the Parent AWS Account.
It will also configure Terraform Backend configurations so state is managed within Gitlab.

#### accountConfiguration (Folder)

This folder contains all the terraform code to apply account guardrails. All resources in this stage are created within each child AWS Account.
It will also configure Terraform Backend configurations so state is managed within Gitlab.

#### accountVendorConfiguration (Folder)

This folder contains all the terraform code to create EKS Clusters, EKS Nodes, and EFS. These resources are only applied when parameters are set to true, ie **"ekscluster": true**. 
It also configures Terraform Backend configurations so state is managed within Gitlab and creates individual ISV specific JSON files which are used as Terraform Locals. 
**As additional resources are added, additional state configurations may be needed. Be sure to make sure state files are consistent with the desired state of each deployment**

#### modules (Folder)

This includes the modules used for each Terraform resource. The modules are broken down into consumable pieces in Gitlab stages. These modules should be removed in production code to decouple any dependencies.

#### accountConfig.py

This script will generate a dynamic Gitlab CI Yaml file account_config.yml. This is used to trigger account guardrails on each account. Things like monitoring, logging, etc.

#### accountVendorConfig.py

This script will generate a dynamic Gitlab CI Yaml file account_vendor_config.yml. This is used to trigger account specific resources. Things like EKS, EFS, etc. The file will only create the necessary stages based on values provided in aws_acounts.json. For example, the ekscluster creation only happens if **"ekscluster": true**.

#### account_config.yml

This file is generated within the pipeline itself and is not a file within the repository. A python script runs during the 'generate_account_pipelines' stage and creates this file. It is then used as the CI file for the downstream trigger 'account_guardrails'. It will create stages for each account and run essential guardrails.
*Python Script: accountConfig.py*

#### account_vendor_config.yml

This file is generated within the pipeline itself and is not a file within the repository. A python script runs during the 'vendorConfig-CI' stage and creates this file. It is then used as the CI file for the downstream trigger 'account_vendor_pipeline_trigger'. It will create stages for each account and run essential guardrails.
*Python Script: accountVenforConfig.py*

#### aws_accounts.json

This file is passed through each stage of the pipeline as an artifact.
After the accounts are created, account_id is added into the file.
After the VPCs are created all VPCs, Subnets, Tags, and other Terraform
Outputs are added as well. This information is used in later stages
to pull in the proper IDs for each ISV. VPCs are created in the parent account
and shared to each child account using AWS Resource Access Manager.

#### matchTerraformOuputs.py

This script takes the VPC Creation output and adds the AccountIDs/VPC/Subnets IDs for each specific account and adds them into the aws_accounts.json file. This is then passed as an artifact to later stages with the IDs necessary to tag and deploy resources.

#### terraform_checks.sh

This script runs a few Terraform checks against formatting.

##### Connect to new EKS Cluster

aws eks update-kubeconfig --name <ClusterName> --region us-west-2 --role-arn arn:aws:iam::<AccountID>:role/vault_assume_role

Mavenir-AZ example:
aws eks update-kubeconfig --name mavenir-az-eksbeta1 --region us-west-2 --role-arn arn:aws:iam::808448958628:role/vault_assume_role
