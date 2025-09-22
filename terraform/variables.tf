variable "docker_image_uri" {
  description = "The full Docker image URI from ECR to deploy"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-south-1"
}

variable "aws_access_key_id" {
  description = "AWS access key for ECR login"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret key for ECR login"
  type        = string
  sensitive   = true
}
