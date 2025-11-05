output "release_name" {
  description = "Helm release name for metrics-server"
  value       = helm_release.metrics_server.name
}

output "namespace" {
  description = "Namespace where metrics-server is deployed"
  value       = helm_release.metrics_server.namespace
}

output "version" {
  description = "Metrics Server chart version"
  value       = helm_release.metrics_server.version
}
