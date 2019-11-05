.PHONY: init
init:
	@ terraform init

.PHONY: upgrade
upgrade:
	@ terraform 0.12upgrade

.PHONY: validate
validate:
	@ terraform validate

.PHONY: plan
plan:
	@ terraform plan

.PHONY: apply
apply:
	@ terraform apply

.PHONY: destroy
destroy:
	@ terraform destroy

.PHONY: clean
clean:
	@ rm -rf .terraform terraform.tfstate terraform.tfstate.backup

.PHONY: purge
purge:
	@ rm -rf data kubernetes.tf versions.tf
