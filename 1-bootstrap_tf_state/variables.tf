variable "bucket_name" {
  description = "Name of the bucket that stores the terraform state"
  type        = string
  default     = "argocd-eks-demo-app-terraform-state-ajara"
}
