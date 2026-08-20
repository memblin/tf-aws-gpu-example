output "instance_id" {
  description = "EC2 instance id."
  value       = module.ec2_instance.id
}

output "public_ip" {
  description = "Auto-assigned public IPv4 address."
  value       = module.ec2_instance.public_ip
}

output "private_ip" {
  description = "Auto-assigned private IPv4 address."
  value       = module.ec2_instance.private_ip
}

output "public_dns" {
  description = "Public DNS name."
  value       = module.ec2_instance.public_dns
}

output "security_group_id" {
  description = "Security group id (looked up from terraform/envs/base)."
  value       = data.aws_security_group.gpu.id
}

output "ssh_command" {
  description = "Convenience SSH command (assumes the ubuntu user)."
  value       = "ssh ubuntu@${module.ec2_instance.public_ip}"
}

output "llama_endpoint" {
  description = "llama-server API base URL, built from the instance's AWS dynamic DNS name. Only reachable from base's gpu_instance_allowed_cidr."
  value       = "http://${module.ec2_instance.public_dns}:${var.llama_port}"
}

output "llama_health_url" {
  description = "Readiness endpoint. Returns 503 while the model loads, 200 once serving."
  value       = "http://${module.ec2_instance.public_dns}:${var.llama_port}/health"
}

output "console_output_command" {
  description = "Reads the boot-to-serving timing line from the serial console, without needing SSH."
  value       = "aws ec2 get-console-output --region ${data.aws_region.current.region} --instance-id ${module.ec2_instance.id} --output text | grep llama-bootstrap"
}

output "timing_log_command" {
  description = "Reads the boot-to-serving timing log over SSH."
  value       = "ssh ubuntu@${module.ec2_instance.public_ip} 'cat /var/log/llama-bootstrap-timing.log'"
}
