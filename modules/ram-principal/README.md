# Module definition

This module will associate VPC and subnet resources to the proper AWS Account that is created earlier in the pipeline. This provides a way to centralize management in a parent account while giving child accounts access to only the specific ISV resources

## Module example use

The artifact containing account information is *aws_accounts.json* in the root directory.
Each *IsvAccount* will get subnets assigned from the VPC Module that is created from *vpc_cidr*. The ISV specific resources are then shared to the child account using AWS RAM.
This currently includes 2 Public Subnets, 2 Private-App Subnets, 2 Private-DB Subnets, and 2 Multus Subnets.
The secondary CIDR is used to create Multus Subnets.

### JSON Detail Template/Breakdown

Replace values including '<>'

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
                "eks_node_desired": 0,
                "eks_node_min": 0,
                "eks_node_max": 0,
                "eks_node_type": "<InstanceType>",
                "eks_node_disksize": <SizeInGb>,
                "clustername": "01",
                "s3_bucket": <Boolean, true/false>,
                "db_module": <Boolean, true/false>
              }
          }
      }
  }
}```
