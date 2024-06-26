# ArgoCD Namespace creation
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

# Prometheus stack namespace creation
resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

# Prometheus stack Helm chart deployment. This deploys Prometheus, Grafana and Alert Manager
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "45.28.1"
  values = [
    <<-EOF
    defaultRules:
      rules:
        # access limited by EKS
        etcd: false
        kubeSchedulerAlerting: false
        kubeSchedulerRecording: false
    EOF
  ]

  depends_on = [
    kubernetes_namespace.prometheus
  ]
}
