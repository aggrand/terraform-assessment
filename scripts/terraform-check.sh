#!/usr/bin/env sh

set -eoux pipefail

terraform fmt -recursive
tflint --recursive
# TODO: This is very verbose.
find live -type d -exec echo "Validating dir {}" \; -execdir terraform validate \;
checkov -d .
