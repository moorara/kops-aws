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
  value       = slice(data.aws_availability_zones.available.names, 0, local.az_len)
  description = "A list of availability zones."
}

output "kops_encrypted_secret" {
  value       = aws_iam_access_key.kops.encrypted_secret
  description = "The encrypted AWS Secret Access Key for kops user."
}
