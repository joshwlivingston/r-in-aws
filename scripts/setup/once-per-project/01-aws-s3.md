# Setting Up S3 Bucket for terraform state file

1. Create the S3 bucket that will host the terraform state 

```
aws s3 mb s3://cmpex-tfstate --region us-east-1
```

2. Create a file `lifecycle.json` that defines the retention period for versioning

```json
{
    "Rules": [
        {
            "ID": "CleanupOldVersions",
            "Status": "Enabled",
            "Filter": {
                "Prefix": ""
            },
            "NoncurrentVersionExpiration": {
                "NoncurrentDays": 90
            }
        }
    ]
}
```

2. Enable versioning on the s3 bucket, using defined lifecycle

```
aws s3api put-bucket-lifecycle-configuration --bucket cmpex-tfstate --lifecycle-configuration file://lifecycle.json
```

3. Block public access

```
aws s3api put-public-access-block --bucket cmpex-tfstate --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

4. Enable encryption

```
aws s3api put-bucket-encryption --bucket cmpex-tfstate --server-side-encryption-configuration "{\"Rules\": [{\"ApplyServerSideEncryptionByDefault\": {\"SSEAlgorithm\": \"AES256\"}}]}"
```

If you encrypt _after_ uploading the first state file (i.e., `terraform init`),
you must run a separate command to encrypt the existing state file.

```
aws s3 cp s3://cmpex-tfstate/ s3://cmpex-tfstate/ --recursive --sse AES256
```
