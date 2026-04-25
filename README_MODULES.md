# Terraform EC2 Modules

This directory contains a modular Terraform configuration for creating EC2 instances across multiple environments (dev and qa) with root and child modules.

## Directory Structure

```
terraform/
├── modules/
│   └── ec2/                          # Child module for EC2 resources
│       ├── main.tf                   # EC2, Security Groups, CloudWatch resources
│       ├── variables.tf              # Module input variables
│       └── outputs.tf                # Module outputs
├── environments/
│   ├── dev/                          # Dev environment (root module)
│   │   ├── main.tf                   # Provider config and module call
│   │   ├── variables.tf              # Environment variables
│   │   ├── terraform.tfvars          # Dev environment values
│   │   └── outputs.tf                # Output values
│   └── qa/                           # QA environment (root module)
│       ├── main.tf                   # Provider config and module call
│       ├── variables.tf              # Environment variables
│       ├── terraform.tfvars          # QA environment values
│       └── outputs.tf                # Output values
└── README.md                         # This file
```

## Features

### Child Module (modules/ec2)
- **EC2 Instances**: Creates configurable number of instances with custom instance type
- **Security Groups**: Manages ingress/egress rules for SSH (22), HTTP (80), and HTTPS (443)
- **AMI Selection**: Automatically fetches the latest Amazon Linux 2 AMI
- **CloudWatch Monitoring**: Enables detailed monitoring and CPU utilization alarms
- **EBS Encryption**: Supports encrypted root volumes
- **Metadata Service v2**: Enforces IMDSv2 for enhanced security

### Root Modules (environments/dev and environments/qa)
- **Environment Isolation**: Separate Terraform state and configuration per environment
- **Consistent Tagging**: Applies common tags to all resources
- **Backend Configuration**: Commented S3 backend setup for state management
- **Variable Validation**: Input validation for security and best practices

## Configuration

### Before Deployment

1. **Update terraform.tfvars** in both `environments/dev` and `environments/qa`:
   - `vpc_id`: Your AWS VPC ID
   - `subnet_ids`: Your subnet IDs
   - `key_pair_name`: Your SSH key pair name
   - `ssh_cidr_blocks`: Allowed CIDR blocks for SSH access
   - Adjust `instance_count` and `instance_type` as needed

2. **Enable S3 Backend** (optional but recommended):
   ```bash
   # Create S3 bucket and DynamoDB table for state management
   aws s3 mb s3://my-terraform-state-dev --region us-east-1
   aws s3 mb s3://my-terraform-state-qa --region us-east-1
   
   # Uncomment the backend block in environments/dev/main.tf and environments/qa/main.tf
   ```

## Deployment

### Deploy Dev Environment
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Deploy QA Environment
```bash
cd environments/qa
terraform init
terraform plan
terraform apply
```

## Environment Differences

| Feature | Dev | QA |
|---------|-----|-----|
| Instance Count | 1 | 2 |
| Instance Type | t3.micro | t3.small |
| Root Volume Size | 20 GB | 30 GB |
| Public IP | Yes | Yes |

## Outputs

After deployment, retrieve outputs:

```bash
# Get EC2 instance IDs
terraform output ec2_instance_ids

# Get private IPs
terraform output ec2_instance_private_ips

# Get security group ID
terraform output security_group_id
```

## Customization

### Adding More Instances
Modify `instance_count` in `terraform.tfvars`:
```hcl
instance_count = 3  # Creates 3 instances
```

### Changing Instance Type
Modify `instance_type`:
```hcl
instance_type = "t3.small"
```

### Modifying Security Rules
Edit `modules/ec2/main.tf` to add/remove ingress/egress rules in the security group section.

## Security Best Practices

- ✅ IMDSv2 enforced
- ✅ EBS encryption enabled
- ✅ Security groups with restrictive rules
- ✅ CloudWatch monitoring enabled
- ✅ Input validation on all variables
- ⚠️ Update `ssh_cidr_blocks` to restrict SSH access to your IP range

## Cleanup

To destroy resources:

```bash
cd environments/dev
terraform destroy

cd ../qa
terraform destroy
```

## Troubleshooting

### VPC or Subnet Not Found
Ensure your VPC ID and subnet IDs exist:
```bash
aws ec2 describe-vpcs --region us-east-1
aws ec2 describe-subnets --region us-east-1
```

### Key Pair Not Found
Ensure your key pair exists:
```bash
aws ec2 describe-key-pairs --region us-east-1
```

### Terraform Plan Issues
Re-initialize if modules change:
```bash
terraform init -upgrade
```

## References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Terraform Modules](https://www.terraform.io/language/modules)

## Support

For issues or improvements, refer to the Terraform and AWS documentation.
