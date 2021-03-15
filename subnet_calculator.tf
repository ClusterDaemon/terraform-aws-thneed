module "private_subnets" {
  source          = "hashicorp/subnets/cidr"

  base_cidr_block = var.vpc_cidr

  networks        = [
    for zone in module.az_colocate.availability_zones : {
      name            = zone,
      new_bits        = var.private_subnet_newbits,
    }
  ]

}

module "public_subnets" {
  source          = "hashicorp/subnets/cidr"

  base_cidr_block = var.vpc_cidr

  networks        = concat(
    [
      for subnet in module.private_subnets.networks : {
        name            = null
        new_bits        = var.private_subnet_newbits
      }
    ],
    [
      for zone in module.az_colocate.availability_zones : {
        name            = zone,
        new_bits        = var.public_subnet_newbits,
      }
    ]
  )

}

module "eks_subnets" {
  source          = "hashicorp/subnets/cidr"

  base_cidr_block = module.vpc.vpc_secondary_cidr_blocks[
    index(
      module.vpc.vpc_secondary_cidr_blocks,
      var.eks_cidr
    )
  ]

  networks        = [
    for zone in module.az_colocate.availability_zones : {
      name            = zone
      new_bits        = var.private_subnet_newbits
    }
  ]

}
