.PHONY: clean
clean:
	@ rm -rf .terraform terraform.tfstate terraform.tfstate.backup

.PHONY: init
init:
	@ terraform init

.PHONY: upgrade
upgrade:
	@ terraform 0.12upgrade
	@ sed -i "" "s/0-0-0-0--0/default/g" kubernetes.tf

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
