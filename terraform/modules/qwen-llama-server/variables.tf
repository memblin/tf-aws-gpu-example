# --- instance shape --------------------------------------------------------

variable "name" {
  description = "Name prefix / Name tag for created resources, and the Docker container name unless container_name overrides it."
  type        = string
}

variable "instance_type" {
  description = "GPU EC2 instance type. Must be a g6.* or g6e.* type. Defaults to g6e.xlarge (L40S, 48GB VRAM) — a 27B model at Q8_K_XL does not fit the 24GB L4 in a g6.xlarge."
  type        = string
  default     = "g6e.xlarge"

  validation {
    condition     = can(regex("^g6e?\\.", var.instance_type))
    error_message = "instance_type must be a g6.* or g6e.* instance type."
  }
}

variable "ami_id" {
  description = "Override AMI id. If empty, the Deep Learning Base OSS Nvidia Driver GPU AMI is looked up."
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Root gp3 volume size in GB. If null, defaults to the resolved AMI's own root snapshot size, floored at 25GB."
  type        = number
  default     = null
}

variable "public_key_path" {
  description = "Path to a local SSH public key to import. If set, an AWS key pair is created and used."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Name of an existing AWS key pair. Used only when public_key_path is empty."
  type        = string
  default     = "id_ed25519_aws_ec2"
}

variable "subnet_id" {
  description = "Default-VPC subnet to launch into. If empty, the lowest-sorted subnet is used. Set this if the chosen AZ lacks GPU capacity (InsufficientInstanceCapacity)."
  type        = string
  default     = ""
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile granting read/write access to tkclabs-models, created in terraform/envs/base."
  type        = string
  default     = "tkclabs-gpu-instance-models-access"
}

variable "security_group_name" {
  description = "Name of the security group, created in terraform/envs/base, to look up and attach to the instance."
  type        = string
  default     = "tkclabs-ephemeral-gpu-instance-sg"
}

variable "tags" {
  description = "Additional tags applied to created resources."
  type        = map(string)
  default     = {}
}

# --- model and storage -----------------------------------------------------

variable "models_bucket" {
  description = "S3 bucket holding model artifacts."
  type        = string
  default     = "tkclabs-models"
}

variable "model_repo_path" {
  description = "Prefix under the bucket, reused verbatim as the on-disk and in-container directory layout."
  type        = string
  default     = "unsloth/Qwen3.8-27B-GGUF"
}

variable "model_file" {
  description = "GGUF filename under model_repo_path. Only this file is synced; the sync is an exact-name include, so a sharded model would need a glob instead."
  type        = string
}

variable "models_root" {
  description = "On-instance model root. The DLAMI auto-mounts the instance-store NVMe at /opt/dlami/nvme; it survives reboot but is wiped on stop/start."
  type        = string
  default     = "/opt/dlami/nvme/models"
}

variable "apt_packages" {
  description = "Packages installed at boot before anything else runs."
  type        = list(string)
  default     = ["cmake", "tmux", "nvtop", "unzip", "git", "tree"]
}

# --- container -------------------------------------------------------------

variable "container_image" {
  description = "llama.cpp server image. The cuda13 tag matches the DLAMI's driver."
  type        = string
  default     = "ghcr.io/ggml-org/llama.cpp:server-cuda13"
}

variable "container_name" {
  description = "Docker container name. Falls back to var.name when empty."
  type        = string
  default     = ""
}

# --- llama.cpp server flags ------------------------------------------------

variable "llama_port" {
  description = "Port llama-server binds, published on the host. Must be open in the base security group's gpu_instance_extra_ingress_ports."
  type        = number
  default     = 8080
}

variable "llama_alias" {
  description = "Model alias reported by the API."
  type        = string
  default     = "qwen3.8-27b"
}

variable "llama_api_key" {
  description = "Bearer token required by llama-server. Reaches the instance through user_data and is stored in Terraform state; rotate it like any other credential."
  type        = string
  sensitive   = true
}

variable "ctx_size" {
  description = "Context window in tokens. Lower this first if the instance OOMs, since --fit off means nothing shrinks automatically."
  type        = number
  default     = 262144
}

variable "batch_size" {
  description = "Logical batch size."
  type        = number
  default     = 4096
}

variable "parallel" {
  description = "Number of parallel sequences to decode."
  type        = number
  default     = 1
}

variable "gpu_layers" {
  description = "Layers offloaded to GPU. 99 means all."
  type        = number
  default     = 99
}

variable "flash_attn" {
  description = "llama.cpp --flash-attn value."
  type        = string
  default     = "on"
}

variable "fit" {
  description = "llama.cpp --fit value. Off across all three environments today; exposed so a single environment can be flipped without editing this module."
  type        = string
  default     = "off"
}

variable "cache_type_k" {
  description = "K cache quantization."
  type        = string
  default     = "f16"
}

variable "cache_type_v" {
  description = "V cache quantization."
  type        = string
  default     = "f16"
}

variable "load_mode" {
  description = "llama.cpp --load-mode value."
  type        = string
  default     = "mmap"
}

variable "cache_ram" {
  description = "Host RAM cache in MiB."
  type        = number
  default     = 16384
}

variable "temperature" {
  description = "Sampling temperature."
  type        = number
  default     = 1.0
}

variable "top_k" {
  description = "Top-k sampling cutoff."
  type        = number
  default     = 20
}

variable "top_p" {
  description = "Top-p (nucleus) sampling cutoff."
  type        = number
  default     = 0.95
}

variable "min_p" {
  description = "Min-p sampling cutoff."
  type        = number
  default     = 0.0
}

variable "repeat_penalty" {
  description = "Repetition penalty."
  type        = number
  default     = 1.0
}

variable "presence_penalty" {
  description = "Presence penalty."
  type        = number
  default     = 0.0
}

variable "spec_draft_n_max" {
  description = "Maximum speculative draft tokens."
  type        = number
  default     = 3
}

variable "spec_type" {
  description = "Speculative decoding type."
  type        = string
  default     = "draft-mtp"
}

variable "health_timeout_seconds" {
  description = "How long the bootstrap waits for /health to return 200 before failing. Generous because a 29GiB model load is not fast."
  type        = number
  default     = 1800
}
