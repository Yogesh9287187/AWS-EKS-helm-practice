variable "aws_region" {
  type        = string
  description = "AWS deployment region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Target deployment tier"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the landing zone VPC"
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "dev-eks-cluster"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes control plane version"
  default     = "1.31"
}
variable "aws_profile" {
  type        = string
  description = "AWS CLI profile to use for authentication"
  default     = "admin"
}
