output "vpc" {
  description = "Output object of the entire VPC submodule."
  value = module.vpc
}

output "unmanaged_vpc_endpoints" {
  description = "Attributes of all unmanaged VPC endpoint connections."
  value = [
    for endpoint in module.vpc_endpoint : endpoint
  ]
}

output "public_eks_ids" {
  description = "EKS cluster IDs that may create private and public service load balancers in the primary VPC CIDR. Map keys are cluster prefixes, as supplied via eks_cluster_id_prefixes."
  value = local.eks_ids
}

output "eks_subnet_ids" {
  description = "High-density private subnets dedicated to EKS clusters."
  value = [
    for subnet in aws_subnet.eks : subnet.id
  ]
}

output "tags" {
  description = "Map of common tags that are applied to all resources."
  value = local.common_tags
}
