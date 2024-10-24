package test

import (
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"testing"
	"strings"
)

// TODO: Test uploading and downloading a blob, test that versions exist.

func TestS3(t *testing.T) {
	bucketName := "terraform-assessment-test-bucket-" + strings.ToLower(random.UniqueId())
	opts := &terraform.Options{
		TerraformDir: "../examples/s3",
		Vars: map[string]interface{}{
			"bucket_name": bucketName,
		},
	}
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)
}
