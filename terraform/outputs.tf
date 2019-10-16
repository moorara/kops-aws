# https://www.terraform.io/docs/configuration/outputs.html

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC."
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "The CIDR block of the VPC."
}

output "availability_zones" {
  value       = join(",", slice(data.aws_availability_zones.available.names, 0, local.az_len))
  description = "A comma-separated list of availability zones."
}

output "kops_subdomain" {
  value       = local.subdomain
  description = "The name of DNS zone for kops."
}

output "kops_s3_bucket" {
  value       = aws_s3_bucket.kops.id
  description = "The name of S3 bucket for kops state."
}

output "resource_tags" {
  value       = join(",", [ for k, v in merge(local.common_tags, local.region_tag) : format("%s=%s", k, v) ])
  description = "A comma-separated list of AWS tags."
}

output "kops_encrypted_secret" {
  value       = aws_iam_access_key.kops.encrypted_secret
  description = "The encrypted AWS Secret Access Key for kops user."
}
