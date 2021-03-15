# terraform-aws-thneed

This module aims to create a resilient VPC with strong focus on private interconnectivity.

This module is designed to be able to be used independently, though emits output attributes and stores state in a way that may be used to place EKS clusters within resources this module defines in a highly consistent manner. Additionally, this module is designed to attach its VPC to a Transit Gateway, enabling inter-VPC private networking without peering.

- [terraform-aws-thneed](#terraform-aws-thneed)
  - [Features](#features)
  - [Dependencies](#dependencies)
  - [Input Attributes](#input-attributes)
  - [Output Attributes](#output-attributes)
  - [Resource Types](#resource-types)
  - [Modules](#modules)
  - [Contributing](#contributing)
  - [Change Log](#change-log)
  - [Authors](#authors)

## Features

 - Conditional resource creation.
 - Strong inter-VPC availability zone colocation across accounts.
    - Enables VPC endpoint connectivity with guaranteed network resilience.
    - Keeps AWS networking costs lower by reducing inter-AZ traffic.
 - Efficient automatic subnet allocation.
    - Packs subnets of differing network block size "densely" within a given IPv4 CIDR block.
    - Defines secondary private subnets for database clusters, cache clusters, and Kuberentes clusters in dedicated secondary IPv4 CIDR blocks.
 - Effective inter-VPC connectivity within AWS, enabling private inter-cluster communication patterns.
    - Unmanaged VPC Endpoint connectivity, in addition to AWS-managed VPC endpoint connectivity.
    - Transit gateway attachment.

### Dependencies

Name | Version
--- | ---
Terraform | ~> 0.14.0

### Providers

Name | Version
--- | ---
AWS | => 2.41

## Input Attributes

| Name | Description | Type | Default | Required | 
| --- | --- | --- | --- | --- |
| project\_name | Unique string that describes this deployment as a whole across all environments, and namespaces every resource name. This name is critical when connecting dependent modules, as it is used to reference resources. | string | nil | yes |
| environment | Unique string that namespaces every resource name. This name is critical when connecting dependent infrastructure modules, as it is used to reference resources. | string | nil | yes |
| vpc\_cidr | Primary VPC CIDR block. Take care when using a Transit Gateway to interconnect VPCs, as subnets between interconnected VPCs must not overlap. | string | "10.0.0.0" | yes |
| private\_subnet\_newbits | Amount of additional netmask bits to add to subnets, relative to vpc\_cidr. | number | 2 | no |
| public\_subnet\_newbits | Amount of additional netmask bits to add to subnets, relative to vpc\_cidr offset by private\_subnet\_newbits and az\_count. Should usually be 1-2 bits higher than private\_subnet\_newbits since they occupy the same base CIDR. | number | 4 | no |
| tgw\_cidr | Transit Gateway CIDR block. Take care when allocating TGW subnets, as they must not overlap between attached VPCs. Not supplying a CIDR here will disable TGW attachment. | string | nil | no |
| tgw\_subnet\_newbits | Amount of additional bits added to each subnet, relative to tgw\_cidr. | number | 3 | no |
| eks\_cidr | EKS CIDR block. Not publicly routable. Not providing a CIDR here disables dedicated private EKS cluster subnets. | string | nil | no |
| az\_count\_min | Minimum amount of availability zones in which subnets will be created. | number | 3 | no |
| az\_count\_max | Maximum amount of availability zones in which subnets will be created. | number | 3 | no |
| tgw\_route\_networks | List of CIDR blocks to define as destination networks via the TGW attachment. | list(string) | [] | no |
| tgw\_id | ID of a transit gateway to attach this VPC to. This gateway should already exist. Not providing an ID here disables TGW attachment. | string | nil | no |
| vpc\_endpoints | List of objects that describe non-AWS(customer) VPC endpoint connections. All included endpoint service names are also used to define availability zone occupancy of all subnets. A VPC endpoint service that is set `create = false` will still be used when calculating AZ occupancy. | list(object({ create = bool, service\_name = string, security\_group\_ids = list(string), allowed\_ingress\_rules = list(tuple([ number, number, string ])), allowed\_cidr\_blocks = list(string), auto\_accept = bool, alternate\_private\_dns = object({ name = string, domain = string, zone\_id = string ]) })) | nil | no |
| eks\_cluster\_id\_prefixes | EKS cluster name prefixes that may use the primary CIDR subnets for load balancer creation. Renders an associated output map of namespaced cluster IDs keyed by these prefixes. | list(string) | ["eks"] | no |

## Output Attributes

| Name | Description | Type |
| --- | --- | --- |
| vpc\_id | VPC ID. | object |
| vpc\_endpoint\_ids | VPC endpoint IDs. | list(object) |
| eks\_subnet\_ids | List of EKS subnet IDs | list(string) |
| eks\_ids | Map of EKS cluster IDs which may create load balancers in the primary CIDR space, regardless of their subnet assignment(s). keyed by eks\_cluster\_id\_prefixes. | map(string) |
| tags | Map of common tags that are applied to all resources. | map(string) |

## Resource Types

- aws\_subnet
- aws\_route\_table
- aws\_route\_table\_association

## Modules

| Name | Source |
| --- | --- |
| az\_colocate | https://github.com:ClusterDaemon/terraform-aws-privatelink-az-colocation |
| subnets | hashicorp/subnets/cidr |
| vpc | ClusterDaemon/vpc/aws |
| vpc\_endpoint | https://github.com:ClusterDaemon/terraform-aws-vpc-interface-endpoint-private-dns |
| tgw\_attachment | https://github.com:ClusterDaemon/terraform-aws-transit-gateway-attachment |
