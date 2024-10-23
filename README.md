# Terraform Assessment
submitted by Raiden Worley

## Testing
This repo uses pre-commit. It is recommended to install pre-commit using your package manager of choice then run the following from the repo root:

``` shell
pre-commit install
```

Those do the most basic checks. For more thorough testing (or for those who don't like pre-commits), you can run `make` to see a list of options:

``` shell
$ make
check                          Run all checks
fix                            Run all fixes
test                           Run all tests
terraform-check                Run all terraform checks
terraform-fix                  Run all terraform fixes
terraform-check-fmt            Check Terraform format
terraform-fix-fmt              Fix Terraform format
terraform-tflint               Lint Terraform
terraform-tflint-fix           Fix Terraform linting
terraform-validate             Validate Terraform recursively in subdirectories
terraform-checkov              Run checkov on Terraform
go-check                       Run all golang checks
go-fix                         Run all golang fixes
go-check-fmt                   Check the format of go files
go-fix-fmt                     Fix the format of go files
go-mod-tidy-check              Check that the mod file is current
go-mod-tidy-fix                Update the mod file
go-lint-check                  Run golang linter
go-lint-fix                    Fix golang lint
```

## Code Layout
There are two main subdirectories in this project: `modules` and `live`. The former contains building blocks. The latter contains the configuration for environments. In a real project I would want these in separate repos so that we can use semantic versioning on the modules for better stability and reusability. For simplicity and convenience in this project I kept them together in this repo.

## More Notes
I assumed for the moment that we'll only deploy to one region. The `live` configurations could be expanded to more regions, and a real app would probably want to do this, but the exact nature of that expansion would depend heavily on the app and how it functions, whether we'd want an "active-active" approach, how we'd deal with latency between regions, etc. In such a case we'd probably create separate modules under `live` for each region.
