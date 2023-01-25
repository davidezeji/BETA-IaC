# Module Need to Know

1) The module dynamically assigns the subnet CIDRs at creation. This leverages the use of the Terraform function cidrsubnet() to dynamically create those CIDRs. Unfortunately this also limits the ability to add accounts after the VPC has been deployed as each CIDR is used in order. Since the Beta environment is more of a spin up, spin down deployment the dynamic nature was more valuable than declaring subnet CIDRs with static values.

2) Output to file is outputting all information on the resources. Because of the dynamic nature of the resources this was currently the best way to pull out necessary information. The valuable information is extracted with the 'matchTerraformOuputs.py' file in the Gitlab Pipeline and output into a file 'accounts.json'. The file is a generated artifact that is passed to future stages and not part of this repository.

3) **RAM Share per AWS Doc ["Link"](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-sharing.html) VPC tags and tags for the resources within the shared VPC are not shared with the participants.**
