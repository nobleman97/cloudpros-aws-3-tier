package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type KeyVault struct {
	KvName string            `json:"name"`
	RSG    string            `json:"resource_group_name"`
	Tags   map[string]string `json:"tags"`
}

var expectedCert []string = nil
var expectedKeys []string = nil
var expectedSecret []map[string]interface{} = nil
var expectedKV *KeyVault = nil
var RequiredTags []string = []string{
	"application-id",
	"application",
	"cost-center",
	"env",
	"owner-email",
	"service",
	"version",
	"resource-name",
}

func AssertKeyVaultExists(t *testing.T) {
	keyVault := azure.GetKeyVault(t, expectedKV.RSG, expectedKV.KvName, "")
	assert.Equal(t, expectedKV.KvName, *keyVault.Name)
}

func AssertKeyVaultAreTagged(t *testing.T) {
	keyVault := azure.GetKeyVault(t, expectedKV.RSG, expectedKV.KvName, "")
	actualTags := keyVault.Tags

	if len(actualTags) < 8 {
		err := fmt.Errorf("base tags not applied")
		t.Errorf("%v", err)
	}

	for _, key := range RequiredTags {
		if _, exists := actualTags[key]; !exists {
			err := fmt.Errorf("required tag key not found in tagset: %s", key)
			t.Errorf("%v", err)
			fmt.Printf("%v and %v", actualTags, key)
		}
	}

}

func AssertKeyVaultKeyExist(t *testing.T) {
	for _, keyMap := range expectedKeys {
		keyExists := azure.KeyVaultKeyExists(t, expectedKV.KvName, keyMap)
		assert.True(t, keyExists, "kv-key does not exist")
	}
}

func AssertKeyVaultCertExist(t *testing.T) {
	for _, certMap := range expectedCert {
		keyExists := azure.KeyVaultCertificateExists(t, expectedKV.KvName, certMap)
		assert.True(t, keyExists, "Certificate does not exist")
	}
}

func AssertKeyVaultSecretExist(t *testing.T) {
	for _, secretMap := range expectedSecret {

		for _, key := range secretMap {
			if name, found := key.(map[string]interface{})["name"].(string); found {
				keyExists := azure.KeyVaultSecretExists(t, expectedKV.KvName, name)
				assert.True(t, keyExists, "Secret does not exist")
			}
		}
	}
}

func TestAzureKeyVault(t *testing.T) {
	t.Parallel()

	tfOpts := &terraform.Options{
		TerraformDir: "../",
		VarFiles: []string{
			"tests/terraform.tfvars",
		},
	}

	defer terraform.Destroy(t, tfOpts)
	terraform.InitAndApply(t, tfOpts)

	expectedKV = &KeyVault{}
	terraform.OutputStruct(t, tfOpts, "keyvault", expectedKV)
	expectedCert = terraform.OutputList(t, tfOpts, "cert_name")
	expectedSecret = terraform.OutputListOfObjects(t, tfOpts, "secret_name")
	expectedKeys = terraform.OutputList(t, tfOpts, "key_name")
	t.Run("KeyVault_exists", AssertKeyVaultExists)
	t.Run("KeyVault_is_tagged", AssertKeyVaultAreTagged)
	t.Run("KeyVault_Key_exists", AssertKeyVaultKeyExist)
	t.Run("KeyVault_Cert_exists", AssertKeyVaultCertExist)
	t.Run("KeyVault_Secret_exists", AssertKeyVaultSecretExist)
}
