.DEFAULT_GOAL := help

# TODO: Add back in checkov. It's disabled for now.
TERRAFORM_CHECKS := terraform-check-fmt terraform-tflint terraform-validate
TERRAFORM_FIXES := terraform-fix-fmt terraform-tflint-fix
GO_CHECKS := go-check-fmt go-mod-tidy-check go-lint-check
GO_FIXES := go-fix-fmt go-mod-tidy-fix go-lint-fix
ALL_CHECKS := terraform-check go-check
ALL_FIXES := terraform-fix go-fix

# This self-documentation target is described here: https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: check
check: $(ALL_CHECKS) ## Run all checks

.PHONY: fix
fix: $(ALL_FIXES) ## Run all fixes

.PHONY: test
test: ## Run all tests
	cd test; go test -v -timeout 30m

.PHONY: terraform-check
terraform-check: $(TERRAFORM_CHECKS) ## Run all terraform checks

.PHONY: terraform-fix
terraform-fix: $(TERRAFORM_FIXES) ## Run all terraform fixes

.PHONY: terraform-check-fmt
terraform-check-fmt: ## Check Terraform format
	terraform fmt -recursive -check

.PHONY: terraform-fix-fmt
terraform-fix-fmt: ## Fix Terraform format
	terraform fmt -recursive

.PHONY: terraform-tflint
terraform-tflint: ## Lint Terraform
	tflint --recursive

.PHONY: terraform-tflint-fix
terraform-tflint-fix: ## Fix Terraform linting
	tflint --recursive --fix

# TODO: This is verbose. Maybe we can find the targets more intelligently.
.PHONY: terraform-validate
terraform-validate: ## Validate Terraform recursively in subdirectories
	find live -type d -execdir terraform validate \;

.PHONY: terraform-checkov
terraform-checkov: ## Run checkov on Terraform
	checkov -d .

.PHONY: go-check
go-check: $(GO_CHECKS) ## Run all golang checks

.PHONY: go-fix
go-fix: $(GO_FIXES) ## Run all golang fixes

.PHONY: go-check-fmt
go-check-fmt: ## Check the format of go files
	gofmt -l . | grep . && exit 2 || true

.PHONY: go-fix-fmt
go-fix-fmt: ## Fix the format of go files
	gofmt -w .

.PHONY: go-mod-tidy-check
go-mod-tidy-check: ## Check that the mod file is current
	cd test; go mod tidy -diff

.PHONY: go-mod-tidy-fix
go-mod-tidy-fix: ## Update the mod file
	cd test; go mod tidy

.PHONY: go-lint-check
go-lint-check: ## Run golang linter
	cd test; golangci-lint run

.PHONY: go-lint-fix
go-lint-fix: ## Fix golang lint
	cd test; golangci-lint run --fix
