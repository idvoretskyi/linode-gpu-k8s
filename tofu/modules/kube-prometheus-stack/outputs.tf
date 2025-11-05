output "namespace" {
  description = "Namespace where monitoring stack is deployed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "release_name" {
  description = "Helm release name for kube-prometheus-stack"
  value       = helm_release.kube_prometheus_stack.name
}

output "version" {
  description = "Kube Prometheus Stack chart version"
  value       = helm_release.kube_prometheus_stack.version
}

output "grafana_service" {
  description = "Grafana service name for port-forwarding"
  value       = "${helm_release.kube_prometheus_stack.name}-grafana"
}

output "prometheus_service" {
  description = "Prometheus service name for port-forwarding"
  value       = "${helm_release.kube_prometheus_stack.name}-prometheus"
}

output "alertmanager_service" {
  description = "Alertmanager service name for port-forwarding"
  value       = "${helm_release.kube_prometheus_stack.name}-alertmanager"
}
