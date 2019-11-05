#!/usr/bin/env bash

help='
#
# COMMANDS:
#   ./kops create       Creates the cluster
#   ./kops update       Updates the cluster
#   ./kops delete       Deletes the cluster
#   ./kops template     Generates manifest file
#   ./kops terraform    Generates Terraform code
#
# FLAGS:
#   -m, --master-count         Number of master instances in the cluster (default: 5)
#       --master-size          Instace type for masters in the cluster (default: t2.micro)
#       --master-volume        Size of volumes for master instances in gigabytes (default: 32GB)
#   -n, --node-count           Number of node instances in the cluster (default: 3)
#       --node-size            Instace type for nodes in the cluster (default: t2.micro)
#       --node-volume          Size of volumes for node instances in gigabytes (default: 64GB)
#       --admin-access-cidr    CIDR block for SSH access to the instances in the cluster (default: 0.0.0.0/0)
#       --ssh-access-cidr      CIDR block for administrative access to the cluster (default: 0.0.0.0/0)
#
'

set -euo pipefail


process_args() {
  if [[ $# == 0 ]]; then
    echo "$help"
    exit 1
  fi

  # Declare variables
  cmd=""

  # Default configurations for masters
  master_count=5
  master_size="t2.micro"
  master_volume=32

  # Default configurations for nodes
  node_count=3
  node_size="t2.micro"
  node_volume=64

  # Default CIDRs
  admin_access_cidr="0.0.0.0/0"
  ssh_access_cidr="0.0.0.0/0"

  while [[ $# > 0 ]]; do
    key="$1"
    case $key in
      create|update|delete|template|terraform)
        cmd="$1"
        ;;
      -m|--master-count)
        master_count="$2"
        shift
        ;;
      --master-size)
        master_size="$2"
        shift
        ;;
      --master-volume)
        master_volume="$2"
        shift
        ;;
      -n|--node-count)
        node_count="$2"
        shift
        ;;
      --node-size)
        node_size="$2"
        shift
        ;;
      --node-volume)
        node_volume="$2"
        shift
        ;;
      --admin-access-cidr)
        admin_access_cidr="$2"
        shift
        ;;
      --ssh-access-cidr)
        ssh_access_cidr="$2"
        shift
        ;;
    esac
    shift
  done
}

read_cluster_info() {
  cd infra-terraform

  cluster_name="$(terraform output kops_subdomain)"
  echo -e "\033[1;36m cluster_name=$cluster_name \033[0m"

  s3_bucket="s3://$(terraform output kops_s3_bucket)"
  echo -e "\033[1;36m s3_bucket=$s3_bucket \033[0m"

  cd ..
}

read_config_params() {
  cd infra-terraform

  availability_zones="$(terraform output availability_zones)"
  dns_zone="$(terraform output kops_subdomain)"
  vpc_id="$(terraform output vpc_id)"
  private_subnets="$(terraform output private_subnet_ids)"
  public_subnets="$(terraform output public_subnet_ids)"
  aws_tags="$(terraform output resource_tags)"

  cd ..
}

generate_ssh_keys() {
  bastion_key="bastion.$cluster_name"

  ssh-keygen -f "$bastion_key" -t rsa -N '' 1> /dev/null
	chmod 400 "$bastion_key"
	mv "$bastion_key" "$bastion_key.pem"
}

create_cluster() {
  read_cluster_info
  read_config_params
  generate_ssh_keys

  kops create cluster "$cluster_name" \
    `#Cloud` \
      --cloud aws \
      --state "$s3_bucket" \
      --cloud-labels "$aws_tags" \
    `#Networking` \
      --topology private \
      --networking weave \
      --vpc "$vpc_id" \
      --subnets "$private_subnets" \
      --utility-subnets "$public_subnets" \
    `#Masters` \
      --master-zones "$availability_zones" \
      --master-count "$master_count" \
      --master-size "$master_size" \
      --master-volume-size "$master_volume" \
    `#Nodes` \
      --zones "$availability_zones" \
      --node-count "$node_count" \
      --node-size "$node_size" \
      --node-volume-size "$node_volume" \
    `#Security` \
      --authorization RBAC \
      --admin-access "$admin_access_cidr" \
      --bastion \
      --ssh-public-key "$bastion_key.pub" \
      --ssh-access "$ssh_access_cidr" \
    `#DNS` \
      --dns public \
      --dns-zone "$dns_zone"
}

update_cluster() {
  read_cluster_info

  kops update cluster "$cluster_name" \
    --state "$s3_bucket" \
    --yes
}

delete_cluster() {
  read_cluster_info

  rm -f *.pub *.pem

  kops delete cluster "$cluster_name" \
    --state "$s3_bucket" \
    --yes
}

generate_template() {
  read_cluster_info
  read_config_params
  generate_ssh_keys

  kops create cluster "$cluster_name" \
    `#Cloud` \
      --cloud aws \
      --state "$s3_bucket" \
      --cloud-labels "$aws_tags" \
    `#Networking` \
      --topology private \
      --networking weave \
      --vpc "$vpc_id" \
      --subnets "$private_subnets" \
      --utility-subnets "$public_subnets" \
    `#Masters` \
      --master-zones "$availability_zones" \
      --master-count "$master_count" \
      --master-size "$master_size" \
      --master-volume-size "$master_volume" \
    `#Nodes` \
      --zones "$availability_zones" \
      --node-count "$node_count" \
      --node-size "$node_size" \
      --node-volume-size "$node_volume" \
    `#Security` \
      --authorization RBAC \
      --admin-access "$admin_access_cidr" \
      --bastion \
      --ssh-public-key "$bastion_key.pub" \
      --ssh-access "$ssh_access_cidr" \
    `#DNS` \
      --dns public \
      --dns-zone "$dns_zone" \
    `#Template` \
      --dry-run \
      --output yaml > ./kops-template/cluster.yaml
}

generate_terraform() {
  read_cluster_info
  read_config_params
  generate_ssh_keys

  kops create cluster "$cluster_name" \
    `#Cloud` \
      --cloud aws \
      --state "$s3_bucket" \
      --cloud-labels "$aws_tags" \
    `#Networking` \
      --topology private \
      --networking weave \
      --vpc "$vpc_id" \
      --subnets "$private_subnets" \
      --utility-subnets "$public_subnets" \
    `#Masters` \
      --master-zones "$availability_zones" \
      --master-count "$master_count" \
      --master-size "$master_size" \
      --master-volume-size "$master_volume" \
    `#Nodes` \
      --zones "$availability_zones" \
      --node-count "$node_count" \
      --node-size "$node_size" \
      --node-volume-size "$node_volume" \
    `#Security` \
      --authorization RBAC \
      --admin-access "$admin_access_cidr" \
      --bastion \
      --ssh-public-key "$bastion_key.pub" \
      --ssh-access "$ssh_access_cidr" \
    `#DNS` \
      --dns public \
      --dns-zone "$dns_zone" \
    `#Terraform` \
      --target terraform \
      --out ./kops-terraform
}


process_args "$@"
case "$cmd" in
  create)
    create_cluster
    ;;
  update)
    update_cluster
    ;;
  delete)
    delete_cluster
    ;;
  template)
    generate_template
    ;;
  terraform)
    generate_terraform
    ;;
esac
