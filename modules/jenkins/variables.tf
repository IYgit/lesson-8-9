variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "ecr_repository" {
  description = "ECR repository URL"
  type        = string
}

variable "jenkins_namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Version of the Jenkins Helm chart"
  type        = string
  default     = "4.6.1"
}

variable "storage_class" {
  description = "Назва StorageClass для PersistentVolume"
  type        = string
}