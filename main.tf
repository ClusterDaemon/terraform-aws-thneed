terraform {
  # This code expects module iteration and argument expansion to work.
  required_version = "~> 0.14.0"

  required_providers {
    aws = {
      version = "~> 2.41"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

locals {

  # For resources which are already regionally scoped:
  name = "${ var.project_name }-${ var.environment }"

  common_tags = var.common_tags

}
