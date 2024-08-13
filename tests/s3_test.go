package test

import (
	// "fmt"
	// "strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	// aws_terratest "github.com/aws/aws-sdk-go/aws"
	// "github.com/gruntwork-io/terratest/modules/random"
	// "github.com/aws/aws-sdk-go/aws/session"
	// "github.com/aws/aws-sdk-go/service/s3"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformAwsS3Example(t *testing.T) {
	t.Parallel()

	// expectedName := fmt.Sprintf("terratest-aws-s3-example-%s", strings.ToLower(random.UniqueId()))

	// expectedEnvironment := "Automated Testing"

	// bucket_name := "test_bucket"

	awsRegion := "us-east-1" //aws.GetRandomStableRegion(t, nil, nil)

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/bucket_policies",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			// "bucket_name" : bucket_name,
		// 	"tag_bucket_name":        expectedName,
		// 	"tag_bucket_environment": expectedEnvironment,
		// 	"with_policy":            "true",
			// "region":                 awsRegion,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	bucketID := terraform.Output(t, terraformOptions, "bucket_id")

	// Verify that our Bucket has versioning enabled
	actualStatus := aws.GetS3BucketVersioning(t, awsRegion, bucketID)
	expectedStatus := "Enabled"
	assert.Equal(t, expectedStatus, actualStatus)

	// Verify that our Bucket has a policy attached
	aws.AssertS3BucketPolicyExists(t, awsRegion, bucketID)

	// Verify that our bucket has server access logging TargetBucket set to what's expected
	// loggingTargetBucket := aws.GetS3BucketLoggingTarget(t, awsRegion, bucketID)
	// expectedLogsTargetBucket := fmt.Sprintf("%s-logs", bucketID)
	// loggingObjectTargetPrefix := aws.GetS3BucketLoggingTargetPrefix(t, awsRegion, bucketID)
	// expectedLogsTargetPrefix := "TFStateLogs/"

	// assert.Equal(t, expectedLogsTargetBucket, loggingTargetBucket)
	// assert.Equal(t, expectedLogsTargetPrefix, loggingObjectTargetPrefix)




	// // Create a new AWS session
	// sess, err := session.NewSession(&aws.Config{
	// 	Region: aws.String(awsRegion)},
	// )
	// if err != nil {
	// 	t.Fatalf("Failed to create AWS session: %s", err)
	// }

	// s3Client := s3.New(sess)


	// // Test 2: Check if versioning is enabled
	// resp, err := s3Client.GetBucketVersioning(&s3.GetBucketVersioningInput{
	// 	Bucket: aws.String(bucketName),
	// })
}