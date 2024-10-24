package test

import (
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"strings"
	"testing"
)

// TODO: Test uploading and downloading a blob, test that versions exist.

func TestDynamo(t *testing.T) {
	bucketName := "terraform-assessment-test-table-" + strings.ToLower(random.UniqueId())
	opts := &terraform.Options{
		TerraformDir: "../examples/dynamo",
		Vars: map[string]interface{}{
			"table_name": bucketName,
		},
	}
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)
}
