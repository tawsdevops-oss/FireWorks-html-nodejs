variable "region" {
  default = "ap-south-2"
}

variable "app_name" {
  default = "my-app"
}

variable "image_url" {
  description = "ECR image URL"
}

variable "container_port" {
  default = 3000
}