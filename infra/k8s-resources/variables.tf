variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "argocd_namespace" {
  description = "The Kubernetes namespace in which to install ArgoCD."
  type        = string
  default     = "argocd"
}
