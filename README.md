# kops-aws

## Prerequisites

You need to have the following tools installed:

  - [aws](https://github.com/aws/aws-cli)
  - [kops](https://github.com/kubernetes/kops/blob/master/docs/install.md)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl)
  - [Keybase](https://keybase.io)
  - [Terraform](https://www.terraform.io)

A _Keybase_ username with a key pair is required for encrypting the AWS Secret Access Key
for _kops_ user by Terraform and decrypting it on your local machine.

## Quick Start

### Prerequisites

You need to have the following AWS resources:

  - A **Route53 Hosted Zone** for your domain
  - A **S3 Bucket** for Terraform backend state named as `terraform.<domain_name>`

### Preparation

The `infra-terraform` project will create the following resources for kops:

  - IAM (_Group_ and _User_)
  - S3 (_Bucket_)
  - Route53 (_Hosted Zone_ and _Records_)
  - VPC (_VPC_, _Subnets_, _Elastic IPs_, _Gateways_, _Route Tables_, etc.)

Change the directory to `infra-terraform` project and
create a file named `terraform.tfvars` with the following variables set.

```
access_key       = "..."
secret_key       = "..."
region           = "..."
environment      = "..."
domain           = "..."
keybase_username = "..."
az_count         = 3|5
create_subnets   = true|false
enable_vpc_logs  = true|false
```

Now, run the following commands to deploy the infrastructure resources.

```
make keys init plan
make apply
```

### kops

After the `infra-terraform` project is successfully deployed,
change the directory to root and run the following command:

```
./kops.sh create
```

If no error, you can run the following command to actaully deploy the cluster:

```
./kops.sh update
```

For deleting the cluster, run the following command:

```
./kops.sh delete
```

### Manifest

### Terraform

## TO-DO

  - [x] Using kops commands
  - [ ] Using kops _manifest_ and _template_
  - [ ] Generating _Terraform_ code from kops
  - [ ] Configuring generated terraform code to use the right AWS credentials

## References

  - [Docs](https://github.com/kubernetes/kops/tree/master/docs)

### Getting Started

  - [AWS](https://github.com/kubernetes/kops/blob/master/docs/getting_started/aws.md)
  - [Bastion](https://github.com/kubernetes/kops/blob/master/docs/bastion.md)

### API

  - [Manifest](https://github.com/kubernetes/kops/blob/master/docs/manifests_and_customizing_via_api.md)
  - [Cluster Spec](https://github.com/kubernetes/kops/blob/master/docs/cluster_spec.md)
  - [Instance Groups](https://github.com/kubernetes/kops/blob/master/docs/instance_groups.md)
  - [Cluster Templating](https://github.com/kubernetes/kops/blob/master/docs/operations/cluster_template.md)

### Networking

  - [Networking](https://github.com/kubernetes/kops/blob/master/docs/networking.md)
  - [Topology](https://github.com/kubernetes/kops/blob/master/docs/topology.md)
  - [Existing VPC](https://github.com/kubernetes/kops/blob/master/docs/run_in_existing_vpc.md)

### Operations

  - [High Availability](https://github.com/kubernetes/kops/blob/master/docs/operations/high_availability.md)
  - [etcd Backup/Restore](https://github.com/kubernetes/kops/blob/master/docs/operations/etcd_backup_restore_encryption.md)
  - [Updates & Upgrades](https://github.com/kubernetes/kops/blob/master/docs/operations/updates_and_upgrades.md)
  - [Upgrades & Migrations](https://github.com/kubernetes/kops/blob/master/docs/operations/cluster_upgrades_and_migrations.md)
