locals {

  # Validate dynamic object input to vpc_endpoints variable.
  # This is a good place to set defaults that make attributes optional via try().
  vpc_endpoints = var.vpc_endpoints != [{"_" = "_"}] ? [
    for endpoint in var.vpc_endpoints : {

      create           = try(tobool(endpoint.create), true)

      name = format(
        "%s-%s",
        coalesce(reverse(split("-", tostring(endpoint.service_name)))...),
        local.name
      )

      service_name     = tostring(endpoint.service_name),

      alternate_private_dns = {
        name = try(tomap(endpoint.alternate_private_dns), {name = ""}).name
        domain = try(tomap(endpoint.alternate_private_dns), {domain = ""}).domain
        zone_id = try(tomap(endpoint.alternate_private_dns), {zone_id = ""}).zone_id
      }

      security_group_ids = [
        for id in try(tolist(endpoint.security_group_ids, ["_"])) : tostring(id)
      ]

      allowed_ingress_rules = [
        for rule in try(
          tolist(endpoint.allowed_ingress_rules),
          [[0, 0, "-1"]]
        ) : [
          try(tonumber(rule[0]), 0),
          try(tonumber(rule[1]), 0),
          try(tostring(rule[2]), "-1")
        ]
      ]

      allowed_cidr_blocks = [
        for block in try(tolist(endpoint.allowed_cidr_blocks), ["_"]): tostring(block)
      ]

      auto_accept = try(tobool(endpoint.auto_accept), false)
    }
  ] : var.vpc_endpoints

}

module "vpc_endpoint" {
  source = "git@github.com:ClusterDaemon/terraform-aws-unmanaged-endpoint.git?ref=v0.1.1"
  count  = local.vpc_endpoints != [{"_" = "_"}] ? length(local.vpc_endpoints) : 0

  create_resources = local.vpc_endpoints[count.index].create

  name                      = local.vpc_endpoints[count.index].create
  vpc_id                    = module.vpc.vpc_id
  vpc_endpoint_service_name = local.vpc_endpoints[count.index].service_name

  # Make sure the endpoint shares AZs with its requested endpoint service.
  subnet_ids = [
    for subnet in range(
      min(
        length(
          module.az_colocate.vpc_endpoint_service_attributes[
            tostring(local.vpc_endpoints[count.index].service_name)
          ].availability_zones
        ),
        var.az_count_min
      )
    ) : module.vpc.private_subnets[subnet]
  ]

  security_group_ids           = local.vpc_endpoints[count.index].security_group_ids
  security_group_ingress_rules = local.vpc_endpoints[count.index].allowed_ingress_rules
  security_group_cidr_blocks   = local.vpc_endpoints[count.index].allowed_cidr_blocks
  alternate_private_dns        = local.vpc_endpoints[count.index].alternate_private_dns

  tags = local.common_tags

}
