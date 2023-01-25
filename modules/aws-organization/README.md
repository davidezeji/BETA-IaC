# Module definition

This module will create a new AWS account within an existing AWS Organization. Each account requires a unique email address and is designed to utilize an existing OU_ID.

## Module example use

The artifact with account information is *aws_accounts.json* in the root directory.
Each *IsvAccount* will be created as a new AWS Account.  

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
