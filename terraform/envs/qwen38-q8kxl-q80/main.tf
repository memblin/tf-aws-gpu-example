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

  name          = "qwen38-q8kxl-q80"
  model_file    = "Qwen3.8-27B-UD-Q8_K_XL.gguf"
  cache_type_k  = "q8_0"
  cache_type_v  = "q8_0"
  llama_api_key = var.llama_api_key

  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  tags = merge(
    {
      Quant     = "UD-Q8_K_XL"
      CacheType = "q8_0"
    },
    var.tags,
  )
}
