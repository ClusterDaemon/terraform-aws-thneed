# Define Transit Gateway attachment and related routing
module "tgw_attachment" {
  source = "git@github.com:ClusterDaemon/terraform-aws-tgw-attachment.git?ref=v0.1.0"

  create_resources = var.tgw_id != "" && var.tgw_cidr != "" ? true : false

  vpc_id   = module.vpc.vpc_id
  tgw_id   = var.tgw_id
  # The TGW CIDR value must come from the VPC module,
  # so that it's guaranteed to already exist.
  tgw_cidr = var.tgw_cidr != "" ? module.vpc.vpc_secondary_cidr_blocks[
    index(
      module.vpc.vpc_secondary_cidr_blocks,
      var.tgw_cidr
    )
  ] : ""

  name                          = local.name
  azs                           = module.az_colocate.availability_zones
  route_destination_cidr_blocks = var.tgw_route_networks
  route_table_count             = length(
    module.private_subnets.network_cidr_blocks
  ) + length(
    module.public_subnets.network_cidr_blocks
  )
  route_table_ids               = concat(
    module.vpc.private_route_table_ids,
    module.vpc.public_route_table_ids
  )
  tags = local.common_tags

}
