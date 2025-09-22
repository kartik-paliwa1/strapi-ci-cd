variable "docker_image_uri" {
  description = "The full Docker image URI from ECR to deploy"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-south-1"
}
