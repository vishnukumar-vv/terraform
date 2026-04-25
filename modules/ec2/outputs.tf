output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.ec2_instance[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = aws_instance.ec2_instance[*].private_ip
}

output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances (if associated)"
  value       = aws_instance.ec2_instance[*].public_ip
}

output "instance_dns_names" {
  description = "DNS names of the EC2 instances"
  value       = aws_instance.ec2_instance[*].private_dns
}

output "security_group_id" {
  description = "Security group ID for the EC2 instances"
  value       = aws_security_group.ec2_sg.id
}

output "security_group_name" {
  description = "Security group name for the EC2 instances"
  value       = aws_security_group.ec2_sg.name
}

output "ami_id" {
  description = "AMI ID used for EC2 instances"
  value       = data.aws_ami.amazon_linux_2.id
}

output "cloudwatch_alarm_names" {
  description = "Names of CloudWatch alarms created for EC2 instances"
  value       = aws_cloudwatch_metric_alarm.ec2_cpu[*].alarm_name
}
