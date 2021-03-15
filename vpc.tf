locals {

  secondary_cidr_blocks = [
    var.tgw_cidr,
    var.eks_cidr,
  ]

  eks_ids = {
    for prefix in var.eks_cluster_id_prefixes : prefix => format(
      "%s-%s",
      prefix,
      local.name
    )
  }

}

# Define a public/private VPC with resilient IPv4 routing and secondary specialized CIDRs.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
#  version = "~> 2.41"

  name                   = local.name

  cidr                   = var.vpc_cidr
  secondary_cidr_blocks  = local.secondary_cidr_blocks
  azs                    = module.az_colocate.availability_zones

  private_subnets        = values(module.private_subnets.network_cidr_blocks)
  public_subnets         = values(module.public_subnets.network_cidr_blocks)

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames   = true

  tags                   = local.common_tags

  public_subnet_tags     = merge(
    { for id in local.eks_ids : "kubernetes.io/cluster/${id}" => "shared" },
    { "kubernetes.io/role/elb"                                = "1" }
  )

  private_subnet_tags    = merge(
    { for id in local.eks_ids : "kubernetes.io/cluster/${id}" => "shared" },
    { "kubernetes.io/role/internal-elb"                       = "1" }
  )

}
