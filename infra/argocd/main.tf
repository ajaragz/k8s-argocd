# Namespace creation
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

# ArgoCD Helm chart deployment
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = var.argocd_namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  timeout    = "1200"

  values = [
    file("${path.module}/helm/argo-cd_values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}
