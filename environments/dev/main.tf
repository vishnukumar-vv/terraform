terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment below to use S3 backend for state management
   backend "s3" {
     bucket         = "my-terraform-state-dev"
     key            = "dev/ec2/terraform.tfstate"
     region         = "us-east-1"
     encrypt        = true
     dynamodb_table = "terraform-locks"
   }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "EC2"
    }
  }
}

# Call the EC2 child module
module "ec2" {
  source = "../../modules/ec2"

  aws_region            = var.aws_region
  environment           = var.environment
  instance_count        = var.instance_count
  instance_type         = var.instance_type
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  key_pair_name         = var.key_pair_name
  associate_public_ip   = var.associate_public_ip
  ssh_cidr_blocks       = var.ssh_cidr_blocks
  http_cidr_blocks      = var.http_cidr_blocks
  root_volume_type      = var.root_volume_type
  root_volume_size      = var.root_volume_size
  enable_ebs_encryption = var.enable_ebs_encryption
  enable_monitoring     = var.enable_monitoring
  common_tags           = var.common_tags
}
