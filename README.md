# kops-aws

## Prerequisites

You need to have the following tools installed:

  - [Keybase](https://keybase.io/)
  - [Terraform](https://www.terraform.io)
  - [kops](https://github.com/kubernetes/kops/blob/master/docs/install.md)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)

The Terraform project will create _IAM_ user, _Route53 Hosted Zone_, _S3 Bucket_, and networking infrastructure for _kops_.

A _Keybase_ username with a key pair is required
for encrypting the AWS Secret Access Key for _kops_ user by Terraform and decrypting it on your local machine.

## Quick Start
