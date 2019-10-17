# https://www.terraform.io/docs/configuration/terraform.html
# https://www.terraform.io/docs/backends/index.html
# https://www.terraform.io/docs/backends/types/s3.html
terraform {
  # Equivalent to ">= 0.12, < 1.0"
  required_version = "~> 0.12"
  backend "s3" {
    bucket = "terraform.sourcherry.io"
    key    = "infra"
    region = "us-east-1"
  }
}

# https://www.terraform.io/docs/providers/aws
# https://www.terraform.io/docs/configuration/providers.html#version-provider-versions
provider "aws" {
  # Equivalent to ">= 2.32.0, < 2.0.0"
  version    = "~> 2.32"  
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}