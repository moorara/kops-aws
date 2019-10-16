# https://www.terraform.io/docs/providers/aws/d/availability_zones.html
data "aws_availability_zones" "available" {
  state = "available"
}

# ================================================================================
#  VPC
# ================================================================================

# Guide:
# https://github.com/kubernetes/kops/blob/master/docs/run_in_existing_vpc.md

# https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "main" {
  cidr_block = lookup(var.vpc_cidrs, var.region)

  tags = merge(local.common_tags, local.region_tag, {
    "Name" = local.name
  })
}

# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, local.region_tag, {
    "Name" = local.name
  })
}

# ================================================================================
#  IAM
# ================================================================================

# https://www.terraform.io/docs/providers/aws/r/iam_instance_profile.html
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html
resource "aws_iam_instance_profile" "vpc" {
  count = var.enable_vpc_logs ? 1 : 0

  name = "${local.name}-vpc"
  role = aws_iam_role.vpc[0].name
}

# https://www.terraform.io/docs/providers/aws/r/iam_role.html
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html
resource "aws_iam_role" "vpc" {
  count = var.enable_vpc_logs ? 1 : 0

  name = "${local.name}-vpc"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(local.common_tags, {
    "Name" = format("%s-vpc", local.name)
  })
}

# https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
resource "aws_iam_role_policy" "vpc" {
  count = var.enable_vpc_logs ? 1 : 0

  name = "${local.name}-vpc"
  role = aws_iam_role.vpc[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "${aws_cloudwatch_log_group.vpc[0].arn}"
    }
  ]
}
EOF
}

# ================================================================================
#  CloudWatch
# ================================================================================

# https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogsConcepts.html
resource "aws_cloudwatch_log_group" "vpc" {
  count = var.enable_vpc_logs ? 1 : 0

  name              = "${local.name}-vpc"
  retention_in_days = 90

  tags = merge(local.common_tags, local.region_tag, {
    "Name" = format("%s-vpc", local.name)
  })
}

# https://www.terraform.io/docs/providers/aws/r/flow_log.html
# https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html
resource "aws_flow_log" "vpc" {
  count = var.enable_vpc_logs ? 1 : 0

  iam_role_arn         = aws_iam_role.vpc[0].arn
  log_destination      = aws_cloudwatch_log_group.vpc[0].arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}
