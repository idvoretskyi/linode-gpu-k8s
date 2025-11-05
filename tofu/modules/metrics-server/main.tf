terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Metrics Server - provides resource metrics API for kubectl top and HPA
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.2"
  namespace  = var.namespace

  # Metrics Server configuration using values
  values = [
    yamlencode({
      args = [
        "--kubelet-insecure-tls",
        "--kubelet-preferred-address-types=InternalIP"
      ]
      resources = {
        requests = {
          cpu    = "100m"
          memory = "200Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "400Mi"
        }
      }
      replicas = 2
      podDisruptionBudget = {
        enabled      = true
        minAvailable = 1
      }
    })
  ]
}
