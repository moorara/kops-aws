# ================================================================================
#  IAM
# ================================================================================

# Guide:
# https://github.com/kubernetes/kops/blob/master/docs/aws.md#setup-iam-user

# https://www.terraform.io/docs/providers/aws/r/iam_group.html
resource "aws_iam_group" "kops" {
  name = "kops"
}

# https://www.terraform.io/docs/providers/aws/d/iam_policy.html
resource "aws_iam_group_policy_attachment" "ec2" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# https://www.terraform.io/docs/providers/aws/d/iam_policy.html
resource "aws_iam_group_policy_attachment" "route53" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

# https://www.terraform.io/docs/providers/aws/d/iam_policy.html
resource "aws_iam_group_policy_attachment" "s3" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# https://www.terraform.io/docs/providers/aws/d/iam_policy.html
resource "aws_iam_group_policy_attachment" "iam" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# https://www.terraform.io/docs/providers/aws/d/iam_policy.html
resource "aws_iam_group_policy_attachment" "vpc" {
  group      = aws_iam_group.kops.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

# https://www.terraform.io/docs/providers/aws/r/iam_user.html
resource "aws_iam_user" "kops" {
  name = "kops"

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

# https://www.terraform.io/docs/providers/aws/r/iam_user_group_membership.html
resource "aws_iam_user_group_membership" "kops" {
  user   = aws_iam_user.kops.name
  groups = [ aws_iam_group.kops.name ]
}

# https://www.terraform.io/docs/providers/aws/r/iam_access_key.html
resource "aws_iam_access_key" "kops" {
  user    = aws_iam_user.kops.name
  pgp_key = "keybase:${var.keybase_username}"
}

# ================================================================================
#  Route53
# ================================================================================

# Guide:
# https://github.com/kubernetes/kops/blob/master/docs/aws.md#configure-dns

# https://www.terraform.io/docs/providers/aws/d/route53_zone.html
data "aws_route53_zone" "main" {
  name = "${var.domain}."
}

# https://www.terraform.io/docs/providers/aws/r/route53_zone.html
resource "aws_route53_zone" "kops" {
  name = "api.${var.domain}"

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "dev-ns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = aws_route53_zone.kops.name
  type    = "NS"
  ttl     = "300"

  records = [
    aws_route53_zone.kops.name_servers.0,
    aws_route53_zone.kops.name_servers.1,
    aws_route53_zone.kops.name_servers.2,
    aws_route53_zone.kops.name_servers.3,
  ]
}

# ================================================================================
#  S3
# ================================================================================

# Guide:
# https://github.com/kubernetes/kops/blob/master/docs/aws.md#cluster-state-storage

# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "kops" {
  bucket        = "kops.${var.domain}"
  acl           = "private"
  region        = var.region
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = merge(local.common_tags, local.region_tag, {
    Name = local.name
  })
}
