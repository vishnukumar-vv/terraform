aws_region            = "us-east-1"
environment           = "dev"
instance_count        = 1
instance_type         = "t3.micro"
vpc_id                = "vpc-071e118043cc73bbb"                                  # Your default VPC
subnet_ids            = ["subnet-0611a9085bf715869", "subnet-01512ec52a4d83ca3"] # Dev subnets
key_pair_name         = "Linuxkey"                                               # Your SSH key pair
associate_public_ip   = true
root_volume_type      = "gp3"
root_volume_size      = 20
enable_ebs_encryption = true
enable_monitoring     = true
common_tags = {
  Project     = "TerraformEC2"
  Environment = "dev"
  Terraform   = "true"
}
