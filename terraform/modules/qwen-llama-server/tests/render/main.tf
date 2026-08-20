# Provider-free harness for asserting on the rendered bootstrap script.
#
# `terraform test` targets an entire configuration, and the module itself needs
# AWS data sources (VPC, security group, SSM, AMI) that would require
# credentials or awkward provider mocking. Rendering the template here in
# isolation keeps the test fast, hermetic, and focused on the thing most likely
# to break: Terraform/bash interpolation collisions in the template.
#
# Values below are fixtures. They intentionally match the module's real
# defaults so an assertion failure points at the template, not the fixture.

variable "model_file" {
  description = "GGUF filename under the model prefix."
  type        = string
}

variable "cache_type_k" {
  description = "llama.cpp --cache-type-k value."
  type        = string
}

variable "cache_type_v" {
  description = "llama.cpp --cache-type-v value."
  type        = string
}

variable "name" {
  description = "Instance / container name."
  type        = string
}

output "rendered" {
  value = templatefile("${path.module}/../../templates/bootstrap.sh.tftpl", {
    name                   = var.name
    apt_packages           = "cmake tmux nvtop unzip git tree"
    models_bucket          = "tkclabs-models"
    model_repo_path        = "unsloth/Qwen3.8-27B-GGUF"
    model_file             = var.model_file
    models_root            = "/opt/dlami/nvme/models"
    container_image        = "ghcr.io/ggml-org/llama.cpp:server-cuda13"
    container_name         = var.name
    llama_port             = 8080
    llama_alias            = "qwen3.8-27b"
    llama_api_key          = "test-api-key-not-a-real-secret"
    ctx_size               = 262144
    batch_size             = 4096
    parallel               = 1
    gpu_layers             = 99
    flash_attn             = "on"
    fit                    = "off"
    cache_type_k           = var.cache_type_k
    cache_type_v           = var.cache_type_v
    load_mode              = "mmap"
    cache_ram              = 16384
    temperature            = 1.0
    top_k                  = 20
    top_p                  = 0.95
    min_p                  = 0.0
    repeat_penalty         = 1.0
    presence_penalty       = 0.0
    spec_draft_n_max       = 3
    spec_type              = "draft-mtp"
    health_timeout_seconds = 1800
  })
}
