data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "gpu" {
  name   = var.security_group_name
  vpc_id = data.aws_vpc.default.id
}

# Always resolves to the latest DLAMI, per AWS's own recommended lookup:
# https://docs.aws.amazon.com/dlami/latest/devguide/aws-deep-learning-x86-base-gpu-ami-ubuntu-26-04.html
data "aws_ssm_parameter" "dlami" {
  name = "/aws/service/deeplearning/ami/x86_64/base-oss-nvidia-driver-gpu-ubuntu-26.04/latest/ami-id"
}

# Re-queried by image id so root_volume_size's derivation below works the same
# whether the AMI came from the lookup above or from an explicit var.ami_id.
data "aws_ami" "selected" {
  filter {
    name   = "image-id"
    values = [local.ami_id]
  }
}

locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.dlami.value

  # Deterministic subnet selection: sort() gives a stable pick so a change in
  # the API's return order can't force-replace the instance.
  subnet_id = var.subnet_id != "" ? var.subnet_id : sort(data.aws_subnets.default.ids)[0]

  key_name = (
    var.public_key_path != "" ? module.key_pair[0].key_pair_name :
    var.key_name != "" ? var.key_name :
    null
  )

  ami_root_volume_size = tonumber(
    [for bdm in data.aws_ami.selected.block_device_mappings :
      bdm.ebs.volume_size if bdm.device_name == data.aws_ami.selected.root_device_name
    ][0]
  )
  root_volume_size = var.root_volume_size != null ? var.root_volume_size : max(local.ami_root_volume_size, 25)

  container_name = var.container_name != "" ? var.container_name : var.name

  tags = merge(
    {
      Name = var.name
    },
    var.tags,
  )

  bootstrap = templatefile("${path.module}/templates/bootstrap.sh.tftpl", {
    name                   = var.name
    apt_packages           = join(" ", var.apt_packages)
    models_bucket          = var.models_bucket
    model_repo_path        = var.model_repo_path
    model_file             = var.model_file
    models_root            = var.models_root
    container_image        = var.container_image
    container_name         = local.container_name
    llama_port             = var.llama_port
    llama_alias            = var.llama_alias
    llama_api_key          = var.llama_api_key
    ctx_size               = var.ctx_size
    batch_size             = var.batch_size
    parallel               = var.parallel
    gpu_layers             = var.gpu_layers
    flash_attn             = var.flash_attn
    fit                    = var.fit
    cache_type_k           = var.cache_type_k
    cache_type_v           = var.cache_type_v
    load_mode              = var.load_mode
    cache_ram              = var.cache_ram
    temperature            = var.temperature
    top_k                  = var.top_k
    top_p                  = var.top_p
    min_p                  = var.min_p
    repeat_penalty         = var.repeat_penalty
    presence_penalty       = var.presence_penalty
    spec_draft_n_max       = var.spec_draft_n_max
    spec_type              = var.spec_type
    health_timeout_seconds = var.health_timeout_seconds
  })
}

module "key_pair" {
  count   = var.public_key_path != "" ? 1 : 0
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 3.0"

  key_name   = "${var.name}-key"
  public_key = file(var.public_key_path)

  tags = local.tags
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.4"

  name = var.name

  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  key_name                    = local.key_name
  create_security_group       = false
  vpc_security_group_ids      = [data.aws_security_group.gpu.id]
  associate_public_ip_address = true
  ignore_ami_changes          = true
  iam_instance_profile        = var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : null

  # Editing the bootstrap replaces the instance rather than leaving a running
  # box that no longer matches its definition. Correct for instances that are
  # ephemeral by design.
  user_data                   = local.bootstrap
  user_data_replace_on_change = true

  root_block_device = {
    type      = "gp3"
    size      = local.root_volume_size
    encrypted = true
  }

  tags = local.tags
}
