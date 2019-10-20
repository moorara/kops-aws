#!/usr/bin/env bash

# 1.14.6
# kope.io/k8s-1.14-debian-stretch-amd64-hvm-ebs-2019-08-16

set -euo pipefail


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
  echo -e "\033[1;36m availability_zones=$availability_zones \033[0m"

  dns_zone="$(terraform output kops_subdomain)"
  echo -e "\033[1;36m dns_zone=$dns_zone \033[0m"

  vpc_id="$(terraform output vpc_id)"
  echo -e "\033[1;36m vpc_id=$vpc_id \033[0m"

  private_subnets="$(terraform output private_subnet_ids)"
  echo -e "\033[1;36m private_subnets=$private_subnets \033[0m"

  public_subnets="$(terraform output public_subnet_ids)"
  echo -e "\033[1;36m public_subnets=$public_subnets \033[0m"

  aws_tags="$(terraform output resource_tags)"
  echo -e "\033[1;36m aws_tags=$aws_tags \033[0m"

  cd ..

  master_count=5
  echo -e "\033[1;36m master_count=$master_count \033[0m"

  master_size="t2.micro"
  echo -e "\033[1;36m master_size=$master_size \033[0m"

  node_count=3
  echo -e "\033[1;36m node_count=$node_count \033[0m"

  node_size="t2.micro"
  echo -e "\033[1;36m node_size=$node_size \033[0m"
}

generate_ssh_keys() {
  bastion_key="bastion.$cluster_name"

  ssh-keygen -f "$bastion_key" -t rsa -N '' 1> /dev/null
	chmod 400 "$bastion_key"
	mv "$bastion_key" "$bastion_key.pem"
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
      `# --master-volume-size` \
      `# --master-security-groups` \
    `#Nodes` \
      --zones "$availability_zones" \
      --node-count "$node_count" \
      --node-size "$node_size" \
      `# --node-volume-size` \
      `# --node-security-groups` \
    `#Security` \
      --authorization RBAC \
      --bastion \
      --ssh-public-key "$bastion_key.pub" \
      `# --ssh-access CIDR` \
      `# --admin-access CIDR` \
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
      `# --master-volume-size` \
      `# --master-security-groups` \
    `#Nodes` \
      --zones "$availability_zones" \
      --node-count "$node_count" \
      --node-size "$node_size" \
      `# --node-volume-size` \
      `# --node-security-groups` \
    `#Security` \
      --authorization RBAC \
      --bastion \
      --ssh-public-key "$bastion_key.pub" \
      `# --ssh-access CIDR` \
      `# --admin-access CIDR` \
    `#DNS` \
      --dns public \
      --dns-zone "$dns_zone" \
    `#Terraform` \
      --target terraform \
      --out ./kops-terraform
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
      `# --master-volume-size` \
      `# --master-security-groups` \
    `#Nodes` \
      --zones "$availability_zones" \
      --node-count "$node_count" \
      --node-size "$node_size" \
      `# --node-volume-size` \
      `# --node-security-groups` \
    `#Security` \
      --authorization RBAC \
      --bastion \
      --ssh-public-key "$bastion_key.pub" \
      `# --ssh-access CIDR` \
      `# --admin-access CIDR` \
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

main() {
  cmd="$1"

  case "$cmd" in
    "template")
      generate_template
      ;;
    "terraform")
      generate_terraform
      ;;
    "create")
      create_cluster
      ;;
    "update")
      update_cluster
      ;;
    "delete")
      delete_cluster
      ;;
  esac
}


main "$1"
