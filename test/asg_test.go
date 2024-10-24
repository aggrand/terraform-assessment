package test

import (
	"github.com/gruntwork-io/terratest/modules/terraform"

	"testing"
)

// TODO: Add more tests of scaling
func TestAsg(t *testing.T) {
	opts := &terraform.Options{
		TerraformDir: "../examples/asg",
	}
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)
}
