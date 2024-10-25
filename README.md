# Terraform Assessment
submitted by Raiden Worley

## Developer Setup
This repo uses pre-commit. It is recommended to install pre-commit using your package manager of choice then run the following from the repo root:

``` shell
pre-commit install
```

You also need to install the following with the package manager of your choice: `terraform`, `checkov`, `go`, `golangci-lint`.

You can ensure that most things are correctly set (and that your go packages are downloaded) up by running `make fix` followed by `make check`.

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

The s3 bucket and dynamo tables weren't explicit requirements of the email, but I think having a stable state store would be pretty vital for an application.

### modules/storage/dynamo
This creates a DynamoDB table for terraform state locking. It is very purpose-built for that, only accepting a variable for setting the table's name. Future work could extend it to a general DynamoDB module.

### modules/storage/mysql
This uses RDS to create a database intended for use in an application. It accepts options for a db password and username.

### modules/compute/asg
This module creates an autoscaling group for EC2 instances. It accepts various variables related to the min and max instance count, the AMI to use, a userdata script to run, and subnet_ids and target group ARNs that can be used to attach the module to others (like the load balancer). I think the instance refresh is still not working perfectly and health checks should be added; future work would tackle those.

### modules/services/web-app
This module represents a web app, connecting together the mysql, asg, and alb modules. It accepts variables like min/max instance count, db username and password, and the instance AMI to use. Ideally the instance AMI would represent the totality of the application, allowing us to treat it as immutable infrastructure. In practice for this assessment I used a userdata script. The script confirms that it can reach the database, then creates a static page reporting its status.

### live/global/s3
This directory has the configuration for the s3 store for terraform state.

### live/stage/services/web-app
This directory has the staging environment configuration for the web app.

### live/prod/services/web-app
This directory has the production environment configuration for the web app.

### examples
This directory has examples of several of the modules in use. This serves both as an example of their uses, but also as a test harness for the golang tests.

### testing
This directory has the golang tests. These tests are very simple; mostly just spinning up then destroying the resources, though the ALB test makes a request. There's room for improvement and testing behaviors like replication, detailed responses, etc.


## More Notes
I assumed for the moment that we'll only deploy to one region. The `live` configurations could be expanded to more regions, and a real app would probably want to do this, but the exact nature of that expansion would depend heavily on the app and how it functions, whether we'd want an "active-active" approach, how we'd deal with latency between regions, etc. In such a case we'd probably create separate modules under `live` for each region.

One of the biggest flaws with the current setup is security and networking. Unfortunately I started running out of time for configuring the networking. Ideally we'd make a "vpc" module that would create a vpc in a region, as well as a set of public and private subnets in each AZ. Then we can hide most of our resources above into the private subnets. 

Beyond that, I think developing each of the modules from the ground up, with a steady code-review process and thorough testing would make me a lot more confident in the infrastructure. We'd also want to make an effort to present a clean interface for each module, with an expectation that external users don't know the details. In this example they kind of grew organically.

Better observability and alerting would be needed all-around. As well as a CI/CD process.
