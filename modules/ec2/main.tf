terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create security group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.environment}-ec2-sg-"
  description = "Security group for ${var.environment} EC2 instances"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-ec2-sg"
    }
  )
}

# Ingress rule - SSH
resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_cidr_blocks
  security_group_id = aws_security_group.ec2_sg.id
}

# Ingress rule - HTTP
resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.http_cidr_blocks
  security_group_id = aws_security_group.ec2_sg.id
}

# Ingress rule - HTTPS
resource "aws_security_group_rule" "https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.http_cidr_blocks
  security_group_id = aws_security_group.ec2_sg.id
}

# Egress rule - Allow all outbound traffic
resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg.id
}

# Create EC2 instances
resource "aws_instance" "ec2_instance" {
  count                       = var.instance_count
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_pair_name
  monitoring                  = var.enable_monitoring
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = var.enable_ebs_encryption
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-ec2-instance-${count.index + 1}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Create CloudWatch alarms for EC2 instances
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  count               = var.instance_count
  alarm_name          = "${var.environment}-ec2-cpu-alarm-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when CPU exceeds 80% for ${var.environment} instance ${count.index + 1}"

  dimensions = {
    InstanceId = aws_instance.ec2_instance[count.index].id
  }

  tags = var.common_tags
}
