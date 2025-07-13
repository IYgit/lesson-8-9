output "jenkins_url" {
  description = "URL of the Jenkins service"
  value       = "http://${data.kubernetes_service.jenkins.status.0.load_balancer.0.ingress.0.hostname}:8080"
}

data "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = var.jenkins_namespace
  }

  depends_on = [helm_release.jenkins]
}