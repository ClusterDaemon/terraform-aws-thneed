variable "project_name" {
  description = "Infrastructure deployment name. Enables multiple infrastructure deployments of the same environment and region."
  type = string
}

variable "environment" {
  description = "Environment to target for deployment. Enables multiple infrastructure deployments of the same name and region"
  type = string
}

variable "vpc_cidr" {
  description = "Primary VPC CIDR block."
  type = string
}

variable "private_subnet_newbits" {
  description = "Amount of additional netmask bits to add to subnets, relative to vpc_cidr."
  type = number
  default = 2
}

variable "public_subnet_newbits" {
  description = "Amount of additional netmask bits to add to subnets, relative to vpc_cidr offset by private_subnet_newbits and az_count. Should usually be 1-2 bits higher than private_subnet_newbits since they occupy the same base CIDR."
  type = number
  default = 4
}

variable "tgw_cidr" {
  description = "Transit Gateway CIDR block."
  type = string
  default = ""
}

variable "tgw_subnet_newbits" {
  description = "Amount of additional bits added to each subnet."
  type = number
  default = 3
}

variable "eks_cidr" {
  description = "EKS CIDR block."
  type = string
  default = "192.168.0.0/16"
}

variable "az_count_min" {
  description = "Minimum amount of availability zones in which subnets will be created."
  type = number
  default = 3
}

variable "az_count_max" {
  description = "Maximum amount of availability zones in which subnets will be created."
  type = number
  default = 3
}

variable "tgw_route_networks" {
  description = "List of destination IPv4 networks (in CIDR notation) which are to be routed via the TGW attachment."
  type = list(string)
  default = []
}

variable "tgw_id" {
  description = "ID of the Transit Gateway this VPC should attach to. This gateway should already exist."
  type = string
  default = ""
}

variable "vpc_endpoints" {
  description = "List of objects that define unmanaged VPC endpoint connections. All included endpoint service names are also used to define availability zone occupancy of all subnets unless explicitly overridden by 'availability_zones'. Refer to https://github.com/ClusterDaemon/terraform-aws-unmanaged-endpoint/README.md for available attributes."
  type = list(any)
  default = [{"_" = "_"}]
}

variable "eks_cluster_id_prefixes" {
  description = "EKS cluster name prefixes that may use the primary VPC CIDR for load balancer creation. Renders a map of namespaced cluster IDs in this module's output."
  type = list(string)
  default = ["eks"]
}

variable "common_tags" {
  description = "AWS object tags that are applied to all resources. These tags get merged with resource-specific tags, so they may be overridden. This is especially useful for the 'Name' key, for example."
  type = map(string)
  default = {
    terraform = "managed"
  }
}
