resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.jenkins_namespace
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name
  replace    = true

  values = [
    file("${path.module}/values.yaml")
  ]

  set = [
    {
      name  = "controller.serviceType"
      value = "LoadBalancer"
    },
    {
      name  = "controller.servicePort"
      value = "8080"
    },
    {
      name  = "persistence.storageClass"
      value = var.storage_class
    }
  ]

  wait          = true
  wait_for_jobs = false
  timeout       = 1200

  depends_on = [
    kubernetes_namespace.jenkins
  ]


}