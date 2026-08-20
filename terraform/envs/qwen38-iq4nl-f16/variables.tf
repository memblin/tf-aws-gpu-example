variable "aws_region" {
  description = "AWS region for all resources in this environment."
  type        = string
  default     = "us-west-2"
}

variable "llama_api_key" {
  description = "Bearer token required by llama-server. No default: set it in the git-ignored terraform.tfvars or export TF_VAR_llama_api_key."
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "GPU EC2 instance type."
  type        = string
  default     = "g6e.xlarge"
}

variable "subnet_id" {
  description = "Default-VPC subnet to launch into. Set this if the chosen AZ lacks GPU capacity."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags applied to created resources."
  type        = map(string)
  default     = {}
}
