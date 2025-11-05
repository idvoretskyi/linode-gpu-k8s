variable "namespace" {
  description = "Kubernetes namespace for metrics-server"
  type        = string
  default     = "kube-system"
}
