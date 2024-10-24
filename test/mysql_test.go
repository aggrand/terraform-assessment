package test

import (
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"strings"
	"testing"
)

// TODO: Test db access with username and password, uploading and downloading data
func TestMysql(t *testing.T) {
	userName := "testUser" + strings.ToLower(random.UniqueId())
	password := "test-user-" + strings.ToLower(random.UniqueId())
	opts := &terraform.Options{
		TerraformDir: "../examples/mysql",
		Vars: map[string]interface{}{
			"db_username": userName,
			"db_password": password,
			"multi_az":    false,
		},
	}
	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)
}
