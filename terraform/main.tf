# ---------------------------------------------
# Terraform configuration
# ---------------------------------------------
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "tastylog-tfstate-bucket-xxxxxx" # 任意のS3バケット名
    key    = "tastylog-dev.tfstate"
    region = "ap-northeast-1"
  }
}
