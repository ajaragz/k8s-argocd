terraform {
  backend "s3" {
    bucket = "argocd-eks-demo-app-terraform-state-ajara"
    key    = "argocd/terraform.tfstate"
    region = "us-east-1"
  }
}