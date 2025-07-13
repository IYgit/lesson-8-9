output "jenkins_url" {
  description = "URL of the Jenkins service"
  value       = "http://a3d338368a5dc4fa196b1df4e74f665c-3378911972.eu-central-1.elb.amazonaws.com:8080"
}

output "admin_password" {
  description = "Admin password for Jenkins"
  value       = "H@dyRlwgkI*D%DRR"
  sensitive   = true
}

# data "kubernetes_service" "jenkins" {
#   metadata {
#     name      = "jenkins"
#     namespace = var.jenkins_namespace
#   }

#   depends_on = [helm_release.jenkins]
# }