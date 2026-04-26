# Terraform Remote State (S3) Setup

This folder contains resources to create an S3 bucket and DynamoDB table used for Terraform remote state and locking.

Quick steps to enable S3 backend for an environment (example: `dev`):

1. Create the backend resources (S3 bucket + DynamoDB table):

```bash
cd backend
terraform init
terraform apply -var-file=dev.tfvars
```
#ok
2. Configure the environment to use the created bucket. Edit `environments/dev/main.tf` and enable the `backend "s3"` block. Example values:

- `bucket`: the bucket created by this module (the resource name is `aws_s3_bucket.terraform_state`; its name is `terraform-state-<environment>-<account_id>`)
- `key`: path to the state file, e.g. `dev/terraform.tfstate` or `dev/ec2/terraform.tfstate`
- `region`: AWS region (e.g. `us-east-1`)
- `dynamodb_table`: the DynamoDB table name (default is `terraform-locks-<environment>`)

Example backend block (replace `<bucket-name>` and `<table-name>`):

```hcl
terraform {
  backend "s3" {
    bucket         = "<bucket-name>"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "<table-name>"
  }
}
```

3. Initialize the backend for the environment (this will migrate local state into the remote backend if present):

```bash
cd ../environments/dev
terraform init -reconfigure
```

Notes and warnings:
- You must create the S3 bucket and DynamoDB table before enabling the backend (step 1). The backend cannot point to a bucket that does not yet exist.
- The backend bucket name created by this module depends on the AWS account ID; fill the correct bucket name after you apply the `backend` module.
- Rewriting or moving state can be disruptive; ensure you coordinate with collaborators and back up any existing state files.

If you want, I can (a) apply the `backend` module to create the bucket/table for `dev`, and (b) enable the backend block automatically in `environments/dev/main.tf` after I know the bucket name. Reply which option you prefer.
