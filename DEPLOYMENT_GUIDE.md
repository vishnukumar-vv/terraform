# Terraform AWS Deployment Guide

## Prerequisites Checklist
✅ Terraform v1.14.9+ installed
✅ AWS CLI v2+ installed  
✅ AWS account with appropriate permissions
✅ AWS credentials configured

---

## Step 1: Update AWS Credentials (Completed)
AWS credentials have been configured and stored in `~\.aws\credentials`

---

## Step 2: Update Variable Files with Real Values

Before running Terraform, you need to update the variable files with your actual AWS resource IDs.

### 2a. Edit `environments/dev/dev.tfvars`
Replace placeholder values with your actual resources:

```hcl
aws_region            = "us-east-1"
environment           = "dev"
instance_count        = 1
instance_type         = "t3.micro"
vpc_id                = "vpc-xxxxx"         # Get from AWS Console: VPC Dashboard
subnet_ids            = ["subnet-xxxxx"]    # Get from AWS Console: Subnets
key_pair_name         = "your-key-name"     # Create in AWS Console: EC2 → Key Pairs
associate_public_ip   = true
ssh_cidr_blocks       = ["YOUR_IP/32"]      # Get from: https://checkip.amazonaws.com/
http_cidr_blocks      = ["0.0.0.0/0"]
root_volume_type      = "gp3"
root_volume_size      = 20
enable_ebs_encryption = true
enable_monitoring     = true
common_tags = {
  Project     = "TerraformEC2"
  Environment = "dev"
  Terraform   = "true"
}
```

### 2b. Edit `environments/qa/qa.tfvars`
Update with QA-specific values:

```hcl
aws_region            = "us-east-1"
environment           = "qa"
instance_count        = 2
instance_type         = "t3.small"
vpc_id                = "vpc-yyyyy"         # Different VPC for QA
subnet_ids            = ["subnet-yyyyy", "subnet-zzzzz"]
key_pair_name         = "your-key-name"
associate_public_ip   = true
ssh_cidr_blocks       = ["YOUR_IP/32"]
http_cidr_blocks      = ["0.0.0.0/0"]
root_volume_type      = "gp3"
root_volume_size      = 30
enable_ebs_encryption = true
enable_monitoring     = true
common_tags = {
  Project     = "TerraformEC2"
  Environment = "qa"
  Terraform   = "true"
}
```

---

## Step 3: Initialize Terraform

### Initialize the DEV environment:
```powershell
cd c:\Users\sande\Test\terraform\environments\dev
terraform init
```

**Expected output:**
```
Terraform has been successfully configured!
You may now begin working with Terraform.
```

### Initialize the QA environment:
```powershell
cd c:\Users\sande\Test\terraform\environments\qa
terraform init
```

---

## Step 4: Validate Configuration

### Validate DEV:
```powershell
cd c:\Users\sande\Test\terraform\environments\dev
terraform validate
```

### Validate QA:
```powershell
cd c:\Users\sande\Test\terraform\environments\qa
terraform validate
```

**Expected output:**
```
Success! The configuration is valid.
```

---

## Step 5: Plan Deployment (Review before Apply)

### Plan DEV resources:
```powershell
cd c:\Users\sande\Test\terraform\environments\dev
terraform plan -var-file="dev.tfvars" -out=tfplan
```

This will show:
- ✅ Resources to be created
- Variables being used
- Expected changes

### Plan QA resources:
```powershell
cd c:\Users\sande\Test\terraform\environments\qa
terraform plan -var-file="qa.tfvars" -out=tfplan
```

**Review the plan output carefully!** It shows exactly what will be created.

---

## Step 6: Apply Configuration (Create Resources)

### Apply DEV resources:
```powershell
cd c:\Users\sande\Test\terraform\environments\dev
terraform apply tfplan
```

Terraform will:
1. ✅ Create VPC and subnets
2. ✅ Create security groups
3. ✅ Launch EC2 instances
4. ✅ Configure networking

**Output will show:**
```
Apply complete! Resources: X added, 0 changed, 0 destroyed.

Outputs:
instance_ids = [...]
security_group_id = "sg-xxxxx"
public_ips = [...]
```

### Apply QA resources:
```powershell
cd c:\Users\sande\Test\terraform\environments\qa
terraform apply tfplan
```

---

## Step 7: Verify Resources in AWS Console

### Check EC2 Instances:
1. Go to AWS Console → EC2 → Instances
2. Verify instances are running
3. Note the public/private IPs

### Check Security Groups:
1. AWS Console → EC2 → Security Groups
2. Verify rules are applied correctly

### Check VPC & Subnets:
1. AWS Console → VPC → VPCs
2. Verify subnets are created
3. Check route tables

---

## Step 8: Test Connectivity

### SSH into EC2 instance:
```powershell
ssh -i "C:\path\to\your-key.pem" ec2-user@<PUBLIC_IP>
```

### Verify instance is healthy:
```bash
# Inside the instance:
curl http://localhost      # Test HTTP
ping 8.8.8.8              # Test internet connectivity
```

---

## Common Operations

### View Current State:
```powershell
cd environments/dev
terraform state list        # List all resources
terraform state show aws_instance.ec2_instance[0]  # Show specific resource
```

### Show Outputs:
```powershell
cd environments/dev
terraform output instance_ids
terraform output public_ips
```

### Destroy Resources (Cleanup):
```powershell
cd environments/dev
terraform plan -destroy -var-file="dev.tfvars"
terraform apply -destroy -var-file="dev.tfvars"
```

---

## Troubleshooting

### Error: "vpc_id not found"
**Solution:** Update `vpc_id` in tfvars file with valid VPC ID from AWS

### Error: "InvalidKeyPair.NotFound"
**Solution:** Create EC2 Key Pair in AWS Console first, then update `key_pair_name`

### Error: "InvalidSubnetID.NotFound"
**Solution:** Ensure subnets belong to the VPC specified in `vpc_id`

### Check Logs:
```powershell
$env:TF_LOG = "DEBUG"
terraform plan
$env:TF_LOG = ""  # Disable debug mode
```

---

## Best Practices

✅ **Always run `terraform plan` before `apply`**
✅ **Keep state files safe** (Consider S3 backend in production)
✅ **Use separate .tfvars for each environment**
✅ **Tag all resources** (for cost tracking)
✅ **Destroy test resources** when done (to avoid AWS charges)
✅ **Use `terraform fmt`** to format code consistently

```powershell
terraform fmt -recursive     # Format all files
```

---

## Architecture Overview

```
Terraform Structure:
├── modules/
│   ├── ec2/             # EC2 instances
│   ├── vpc/             # VPC, subnets, gateways
│   └── security_groups/ # Security group rules
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── dev.tfvars   # Environment-specific values
│   └── qa/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── qa.tfvars    # Environment-specific values
└── README_MODULES.md
```

AWS Architecture Created:
```
VPC (10.0.0.0/16)
├── Public Subnets
│   ├── subnet-1 (10.0.1.0/24)
│   └── subnet-2 (10.0.2.0/24)
├── Private Subnets
│   ├── subnet-3 (10.0.10.0/24)
│   └── subnet-4 (10.0.11.0/24)
├── Internet Gateway
├── NAT Gateways
├── Route Tables
└── EC2 Instances
    ├── Security Groups
    ├── Network Interfaces
    └── EBS Volumes
```

---

## Next Steps

1. ✅ Update tfvars with real AWS values
2. ✅ Run `terraform init` in dev environment
3. ✅ Run `terraform plan` to preview changes
4. ✅ Run `terraform apply` to create resources
5. ✅ Verify in AWS Console
6. ✅ Test SSH connectivity
7. ✅ Repeat for QA environment (or destroy DEV if just testing)

Happy Terraforming! 🚀
