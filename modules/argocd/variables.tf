variable "argocd_namespace" {
  description = "The namespace to install Argo CD into."
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "The version of the Argo CD Helm chart to use."
  type        = string
  default     = "5.5.0"
}
