variable "vpc_id" {
  description = "The ID of an existing VPC"
  type        = string
}

variable "subnet_a" {
    type = string
}

variable "subnet_b" {
    type = string
}

variable "subnet_c" {
    type = string
}
variable "eks_name" {}
variable "desired_size" {}
variable "min_size" {}
variable "max_size" {}
variable "instance_types" {}

