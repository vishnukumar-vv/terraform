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

# Security Group for EC2 Instances
resource "aws_security_group" "ec2" {
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

# EC2 - SSH Ingress
resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  security_group_id = aws_security_group.ec2.id
  description       = "SSH access to EC2 instances"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_ssh_cidrs[0]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-ec2-ssh"
    }
  )
}

# EC2 - HTTP Ingress
resource "aws_vpc_security_group_ingress_rule" "ec2_http" {
  security_group_id = aws_security_group.ec2.id
  description       = "HTTP access to EC2 instances"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_http_cidrs[0]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-ec2-http"
    }
  )
}

# EC2 - HTTPS Ingress
resource "aws_vpc_security_group_ingress_rule" "ec2_https" {
  security_group_id = aws_security_group.ec2.id
  description       = "HTTPS access to EC2 instances"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_https_cidrs[0]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-ec2-https"
    }
  )
}

# EC2 - Application Port Ingress
resource "aws_vpc_security_group_ingress_rule" "ec2_app" {
  security_group_id = aws_security_group.ec2.id
  description       = "Application access on port 8080"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_app_cidrs[0]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-ec2-app"
    }
  )
}

# EC2 - All traffic Egress
resource "aws_vpc_security_group_egress_rule" "ec2_all" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-ec2-egress"
    }
  )
}

# Security Group for Application Load Balancer
resource "aws_security_group" "alb" {
  count       = var.enable_alb_sg ? 1 : 0
  name_prefix = "${var.environment}-alb-sg-"
  description = "Security group for ${var.environment} ALB"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-alb-sg"
    }
  )
}

# ALB - HTTP Ingress
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  count             = var.enable_alb_sg ? 1 : 0
  security_group_id = aws_security_group.alb[0].id
  description       = "HTTP access to ALB"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-alb-http"
    }
  )
}

# ALB - HTTPS Ingress
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  count             = var.enable_alb_sg ? 1 : 0
  security_group_id = aws_security_group.alb[0].id
  description       = "HTTPS access to ALB"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-alb-https"
    }
  )
}

# ALB - Egress to EC2
resource "aws_vpc_security_group_egress_rule" "alb_to_ec2" {
  count                        = var.enable_alb_sg ? 1 : 0
  security_group_id            = aws_security_group.alb[0].id
  description                  = "Allow ALB to communicate with EC2 instances"
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-alb-to-ec2"
    }
  )
}

# ALB - All traffic Egress (fallback)
resource "aws_vpc_security_group_egress_rule" "alb_all" {
  count             = var.enable_alb_sg ? 1 : 0
  security_group_id = aws_security_group.alb[0].id
  description       = "Allow all outbound traffic from ALB"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-alb-egress"
    }
  )
}

# Security Group for Database
resource "aws_security_group" "database" {
  count       = var.enable_db_sg ? 1 : 0
  name_prefix = "${var.environment}-db-sg-"
  description = "Security group for ${var.environment} database"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-db-sg"
    }
  )
}

# Database - MySQL/RDS Ingress
resource "aws_vpc_security_group_ingress_rule" "db_mysql" {
  count                        = var.enable_db_sg ? 1 : 0
  security_group_id            = aws_security_group.database[0].id
  description                  = "MySQL access from EC2 instances"
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-db-mysql"
    }
  )
}

# Database - PostgreSQL Ingress
resource "aws_vpc_security_group_ingress_rule" "db_postgres" {
  count                        = var.enable_db_sg ? 1 : 0
  security_group_id            = aws_security_group.database[0].id
  description                  = "PostgreSQL access from EC2 instances"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-db-postgres"
    }
  )
}

# Database - All traffic Egress
resource "aws_vpc_security_group_egress_rule" "db_all" {
  count             = var.enable_db_sg ? 1 : 0
  security_group_id = aws_security_group.database[0].id
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-db-egress"
    }
  )
}

# Security Group for ElastiCache/Redis
resource "aws_security_group" "cache" {
  count       = var.enable_cache_sg ? 1 : 0
  name_prefix = "${var.environment}-cache-sg-"
  description = "Security group for ${var.environment} cache"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-cache-sg"
    }
  )
}

# Cache - Redis Ingress
resource "aws_vpc_security_group_ingress_rule" "cache_redis" {
  count                        = var.enable_cache_sg ? 1 : 0
  security_group_id            = aws_security_group.cache[0].id
  description                  = "Redis access from EC2 instances"
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-cache-redis"
    }
  )
}

# Cache - All traffic Egress
resource "aws_vpc_security_group_egress_rule" "cache_all" {
  count             = var.enable_cache_sg ? 1 : 0
  security_group_id = aws_security_group.cache[0].id
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-cache-egress"
    }
  )
}

# Allow EC2 to communicate with ALB
resource "aws_vpc_security_group_ingress_rule" "ec2_from_alb" {
  count                        = var.enable_alb_sg ? 1 : 0
  security_group_id            = aws_security_group.ec2.id
  description                  = "Allow traffic from ALB to EC2"
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb[0].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-ec2-from-alb"
    }
  )
}
