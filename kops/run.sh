#!/usr/bin/env bash

set -euo pipefail


read_parameters() {
  master_count=5
  echo -e "\033[1;36m master_count=$master_count \033[0m"

  master_size="t2.micro"
  echo -e "\033[1;36m master_size=$master_size \033[0m"

  node_count=3
  echo -e "\033[1;36m node_count=$node_count \033[0m"

  node_size="t2.micro"
  echo -e "\033[1;36m node_size=$node_size \033[0m"

  cd ../terraform

  cluster_name="$(terraform output kops_subdomain)"
  echo -e "\033[1;36m cluster_name=$cluster_name \033[0m"

  s3_bucket="s3://$(terraform output kops_s3_bucket)"
  echo -e "\033[1;36m s3_bucket=$s3_bucket \033[0m"

  dns_zone="$(terraform output kops_subdomain)"
  echo -e "\033[1;36m dns_zone=$dns_zone \033[0m"

  vpc_id="$(terraform output vpc_id)"
  echo -e "\033[1;36m vpc_id=$vpc_id \033[0m"

  availability_zones="$(terraform output availability_zones)"
  echo -e "\033[1;36m availability_zones=$availability_zones \033[0m"

  aws_tags="$(terraform output resource_tags)"
  echo -e "\033[1;36m aws_tags=$aws_tags \033[0m"

  cd -
}

create_cluster() {
  kops create cluster $cluster_name \
    `#Cloud` \
      --cloud aws \
      --state $s3_bucket \
      --cloud-labels $aws_tags \
    `#Networking` \
      --topology private \
      --networking weave \
      --vpc $vpc_id \
      `# --network-cidr` \
      `# --subnets` \
      `# --utility-subnets` \
    `#Masters` \
      --master-zones $availability_zones \
      --master-count $master_count \
      --master-size $master_size \
      `# --master-volume-size` \
      `# --master-security-groups` \
    `#Nodes` \
      --zones $availability_zones \
      --node-count $node_count \
      --node-size $node_size \
      `# --node-volume-size` \
      `# --node-security-groups` \
    `#Security` \
      --bastion \
      --authorization RBAC \
      `# --admin-access CIDR` \
      `# --ssh-access CIDR` \
      `# --ssh-public-key path` \
    `#DNS` \
      --dns public \
      --dns-zone $dns_zone \
    `#Terraform` \
      `# --dry-run` \
      `# --output yaml > $cluster_name.yaml` \
    `#Terraform` \
      `# --target terraform` \
      `# --out .`
}

update_cluster() {
  kops update cluster $cluster_name \
    --state $s3_bucket \
    --yes
}

delete_cluster() {
  kops delete cluster $cluster_name \
    --state $s3_bucket \
    --yes
}


read_parameters

cmd="$1"
case "$cmd" in
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
