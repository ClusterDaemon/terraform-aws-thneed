# Produce an AZ list that is guaranteed to contain AZs which VPC endpoint services occupy.
# This is necessary to avoid conditions that prevent redundant VPC endpoint connectivity,
# or lack of connectivity altogether (which would be a fatal error from the AWS API).
module "az_colocate" {
  source = "git@github.com:ClusterDaemon/terraform-aws-privatelink-az-colocation.git?ref=v0.1.0"

  vpc_endpoint_service_names = [
    for endpoint in local.vpc_endpoints : endpoint.service_name
  ]

  az_count_max               = var.az_count_max
  az_count_min               = var.az_count_min
}
