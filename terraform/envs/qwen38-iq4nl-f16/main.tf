# No `profile` here either — see versions.tf.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "TKC-Labs"
      ManagedBy = "terraform"
    }
  }
}

module "qwen_llama_server" {
  source = "../../modules/qwen-llama-server"

  name          = "qwen38-iq4nl-f16"
  model_file    = "Qwen3.8-27B-IQ4_NL.gguf"
  cache_type_k  = "f16"
  cache_type_v  = "f16"
  llama_api_key = var.llama_api_key

  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  tags = merge(
    {
      Quant     = "IQ4_NL"
      CacheType = "f16"
    },
    var.tags,
  )
}
