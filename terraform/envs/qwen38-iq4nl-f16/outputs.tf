output "llama_endpoint" {
  description = "llama-server API base URL."
  value       = module.qwen_llama_server.llama_endpoint
}

output "llama_health_url" {
  description = "Readiness endpoint."
  value       = module.qwen_llama_server.llama_health_url
}

output "instance_id" {
  description = "EC2 instance id."
  value       = module.qwen_llama_server.instance_id
}

output "public_ip" {
  description = "Auto-assigned public IPv4 address."
  value       = module.qwen_llama_server.public_ip
}

output "private_ip" {
  description = "Auto-assigned private IPv4 address."
  value       = module.qwen_llama_server.private_ip
}

output "public_dns" {
  description = "Public DNS name."
  value       = module.qwen_llama_server.public_dns
}

output "security_group_id" {
  description = "Security group id."
  value       = module.qwen_llama_server.security_group_id
}

output "ssh_command" {
  description = "Convenience SSH command."
  value       = module.qwen_llama_server.ssh_command
}

output "console_output_command" {
  description = "Reads the boot-to-serving timing line from the serial console."
  value       = module.qwen_llama_server.console_output_command
}

output "timing_log_command" {
  description = "Reads the boot-to-serving timing log over SSH."
  value       = module.qwen_llama_server.timing_log_command
}
