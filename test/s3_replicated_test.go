package test

import (
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"strings"
	"testing"
)

// TODO: Test uploading and downloading a blob, test that versions exist, and that it exists in both buckets.

func TestS3Replicated(t *testing.T) {
	bucketName := "terraform-assessment-test-bucket-" + strings.ToLower(random.UniqueId())
	opts := &terraform.Options{
		TerraformDir: "../examples/s3-replicated",
		Vars: map[string]interface{}{
			"bucket_name": bucketName,
		},
	}
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)
}
