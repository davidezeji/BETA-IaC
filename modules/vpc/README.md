# Module definition

This module will create VPCs and subnets resources in the parent AWS Account. This module currently includes 2 Public Subnets, 2 Private-App Subnets, 2 Private-DB Subnets, and 2 Multus Subnets. The module uses the Terraform function cidrsubnet() to assign subnet ranges to each account. Currently this is providing /24 CIDR ranges from the provided *vpc_cidr*. This may be something we need to review and modify for certain ISVs.

## The module requires sharing to be enabled within the Organization before deployment

If it's not enabled you'll get the following
Error: error associating RAM Resource Share: InvalidParameterException: The resource you are attempting to share can only be shared within your AWS Organization. This error may also occur if you have not enabled sharing with your AWS organization, or that onboarding process is still in progress.

Disable/enable with aws cli if issue persists:

```$ aws organizations disable-aws-service-access --service-principal ram.amazonaws.com
$ aws ram enable-sharing-with-aws-organization```

## Module example use

The artifact containing account information is *aws_accounts.json* in the root directory.
Each *IsvAccount* will get subnets assigned from the VPC Module that is created from *vpc_cidr*. The ISV specific resources are then shared to the child account using the ram-principal module.
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
