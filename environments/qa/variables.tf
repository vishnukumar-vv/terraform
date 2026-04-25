variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "qa"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
}

variable "associate_public_ip" {
  description = "Associate public IP"
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks" {
  description = "SSH CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "http_cidr_blocks" {
  description = "HTTP/HTTPS CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root volume size"
  type        = number
  default     = 20
}

variable "enable_ebs_encryption" {
  description = "Enable EBS encryption"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project   = "TerraformEC2"
    Terraform = "true"
  }
}
