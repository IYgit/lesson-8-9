resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  replace    = true

  wait          = true
  wait_for_jobs = false
  timeout       = 1200

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# Коментуємо Application поки що, щоб спочатку встановити ArgoCD
# resource "kubernetes_manifest" "django_app" {
#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "Application"
#     metadata = {
#       name      = "django-app"
#       namespace = kubernetes_namespace.argocd.metadata[0].name
#     }
#     spec = {
#       project = "default"
#       source = {
#         repoURL        = var.repo_url
#         targetRevision = "HEAD"
#         path           = "charts/django-app"
#         helm = {
#           valueFiles = ["values.yaml"]
#         }
#       }
#       destination = {
#         server    = "https://kubernetes.default.svc"
#         namespace = "default"
#       }
#       syncPolicy = {
#         automated = {
#           prune    = true
#           selfHeal = true
#         }
#         syncOptions = [
#           "CreateNamespace=true"
#         ]
#       }
#     }
#   }
# }
