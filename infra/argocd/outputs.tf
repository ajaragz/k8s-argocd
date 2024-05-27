output "argocd_helm_release_status" {
  description = "Status of the ArgoCD helm release"
  value       = helm_release.argocd.status
}
