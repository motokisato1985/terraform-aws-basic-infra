# ---------------------------------------------
# Variables
# ---------------------------------------------
variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "環境名 (dev, stg, prod)"

  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "environment は dev / stg / prod のいずれかにしてください"
  }
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "domain" {
  type        = string
  description = "Domain name used for Route53 / ACM / CloudFront"
}

variable "allowed_admin_cidr" {
  type        = string
  description = "Allowed CIDR for operation access"
}
