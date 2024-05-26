provider "aws" {
  region = var.region
}

# Data source to fetch the EKS cluster info from remote state
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "argocd-eks-demo-app-terraform-state-ajara"
    key    = "eks/terraform.tfstate"
    region = var.region
  }
}

# EKS authentication data for the k8s and helm providers
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

locals {
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = local.cluster_ca_certificate
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca_certificate
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
