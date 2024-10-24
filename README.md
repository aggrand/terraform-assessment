# Terraform Assessment
submitted by Raiden Worley

## Developer Setup
This repo uses pre-commit. It is recommended to install pre-commit using your package manager of choice then run the following from the repo root:

``` shell
pre-commit install
```

## Testing
You can run `make` to see a list of testing options:

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

### modules/networking/alb
This module defines the load balancer. This wasn't an explicit requirement in the email, but since I wanted to allow autoscaling of the EC2 instances, this seemed like a practical requirement so that there's a single point of connection. I used the application load balancer specifically because I assumed we'd be handling HTTP traffic. If there's higher load, or more throughput requirements, then the network load balancer could be used instead.

The alb is definitely not production-ready. More analysis is needed of the WAF settings, possibly extracting them into a separate module. It also needs to configure logging, HTTPS, and options to disallow public access (preventing 0.0.0.0/0).

### modules/storage/s3
This module defines the s3 bucket used for storing terraform state. Creates a bucket with encryption, versioning, and blocked public access. Ideally it could be extended as a general s3 module. Future work can add options to enable SNS, KMS, logging, and configurations for access permissions.

### modules/storage/s3-replicated
This module extends the S3 module above, allowing for replication between two different buckets. While a region-wide outage is rare, it does [happen](https://aws.amazon.com/message/41926/). Since these buckets manage the state for all the infrastructure, that seems sufficiently catastrophic to take this precaution. This module was intended to be an all-in-one s3 bucket with a backup. However, due to the fact that only one replication configuration is allowed per bucket, in the future it may need to be extended to allow a list of buckets to be created outside the module and passed in. This would be more complicatd since permissions and destination rules need to be created for each bucket.

### modules/storage/dynamo
This creates a DynamoDB table for terraform state locking. It is very purpose-built for that, only accepting a variable for setting the table's name. Future work could extend it to a general DynamoDB module.

## More Notes
I assumed for the moment that we'll only deploy to one region. The `live` configurations could be expanded to more regions, and a real app would probably want to do this, but the exact nature of that expansion would depend heavily on the app and how it functions, whether we'd want an "active-active" approach, how we'd deal with latency between regions, etc. In such a case we'd probably create separate modules under `live` for each region.

## Future Work
I'd want to make the Makefile smarter. I prefer to be able to control the entire repo from the root directory, so something to help find and deploy the live modules. Right now it's necessary to enter each directory and run the terraform commands.
