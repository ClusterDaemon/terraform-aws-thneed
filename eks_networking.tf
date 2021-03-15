# High-density private subnets dedicated to EKS.
# This works around the vast majority of address exhaustion issues when using smaller primary CIDRs,
# and it can be expected in many orgs that the routable address space is rather small.

resource "aws_subnet" "eks" {
  for_each = module.eks_subnets.network_cidr_blocks

  vpc_id            = module.vpc.vpc_id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    local.common_tags,
    {
      Name = format("eks-%s-%s", local.name, each.key)
    }
  )

}

# Define internal EKS route tables - one per AZ for resilient NAT.
# Each EKS route table should use a public subnet NAT gateway for internet connectivity.
resource "aws_route_table" "eks" {
  for_each = module.eks_subnets.network_cidr_blocks

  vpc_id = module.vpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    # Find the NAT gateway ID associated with the AZ the current subnet is in.
    nat_gateway_id = module.vpc.natgw_ids[
      index(
        module.az_colocate.availability_zones,
        each.key
      )
    ]
  }

  tags = merge(
    local.common_tags,
    {
      Name = format("eks-%s-%s", local.name, each.key)
    }
  )

}

# Associate EKS subnets with EKS route tables, with repect to AZ.
resource "aws_route_table_association" "eks" {
  for_each = module.eks_subnets.network_cidr_blocks

  route_table_id = aws_route_table.eks[each.key].id
  subnet_id      = aws_subnet.eks[each.key].id
}
