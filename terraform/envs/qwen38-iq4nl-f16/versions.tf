# No `profile` in this backend block, unlike the older environments in this
# repo. The SSO profile name embeds the AWS account number, and backend blocks
# cannot reference variables, so it would have to be a repo-committed literal.
# Credentials come from AWS_PROFILE instead — see .envrc, which is git-ignored.
#
# use_lockfile enables Terraform's native S3 conditional-write locking (1.10+);
# no DynamoDB table needed.
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "tkclabs-tfstate"
    key          = "aws/personal/qwen38-iq4nl-f16/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
  }
}
