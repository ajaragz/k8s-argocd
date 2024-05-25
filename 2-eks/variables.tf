variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "argocd-demo-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "The CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "A list of public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "A list of private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "node_instance_type" {
  description = "The EC2 instance type for the EKS nodes"
  type        = string
  default     = "t3.medium"
}

# Desired number of nodes in the EKS node group
variable "desired_nodes" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

# Maximum number of nodes in the EKS node group
variable "max_nodes" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

# Minimum number of nodes in the EKS node group
variable "min_nodes" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}
