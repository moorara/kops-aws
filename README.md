# kops-aws

## Prerequisites

You need to have the following tools installed:

  - [aws](https://github.com/aws/aws-cli)
  - [kops](https://github.com/kubernetes/kops/blob/master/docs/install.md)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)
  - [Keybase](https://keybase.io)
  - [Terraform](https://www.terraform.io)

The Terraform project will create _IAM_ user, _Route53 Hosted Zone_, _S3 Bucket_, and networking infrastructure for _kops_.

A _Keybase_ username with a key pair is required
for encrypting the AWS Secret Access Key for _kops_ user by Terraform and decrypting it on your local machine.

## Quick Start

### Terraform

### kops

## TO-DO

  - [ ] Using kops _manifesto_ and _templates_
  - [ ] Generating _Terraform_ code from kops
  - [ ] Configuring generated terraform code to use the right AWS credentials

## References

  - [Docs](https://github.com/kubernetes/kops/tree/master/docs)

### Getting Started

  - [AWS](https://github.com/kubernetes/kops/blob/master/docs/aws.md)
  - [Bastion](https://github.com/kubernetes/kops/blob/master/docs/bastion.md)

### API

  - [Manifest](https://github.com/kubernetes/kops/blob/master/docs/manifests_and_customizing_via_api.md)
  - [Cluster Spec](https://github.com/kubernetes/kops/blob/master/docs/cluster_spec.md)
  - [Instance Groups](https://github.com/kubernetes/kops/blob/master/docs/instance_groups.md)
  - [Cluster Templating](https://github.com/kubernetes/kops/blob/master/docs/cluster_template.md)

### Networking

  - [Networking](https://github.com/kubernetes/kops/blob/master/docs/networking.md)
  - [Topology](https://github.com/kubernetes/kops/blob/master/docs/topology.md)
  - [Existing VPC](https://github.com/kubernetes/kops/blob/master/docs/run_in_existing_vpc.md)

### Operations

  - [etcd Backup/Restore](https://github.com/kubernetes/kops/blob/master/docs/etcd/backup-restore.md)
  - [Upgrading Kubernetes](https://github.com/kubernetes/kops/blob/master/docs/upgrade.md)
  - [Upgrading Kubernetes](https://github.com/kubernetes/kops/blob/master/docs/tutorial/upgrading-kubernetes.md)
