variable "cluster_name_prefix" {
  description = "Prefix for the LKE cluster name (will use system username if not set)"
  type        = string
  default     = ""
}

variable "region" {
  description = "Linode region for the cluster"
  type        = string
  default     = "us-ord" # Chicago, US

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]{3}$", var.region))
    error_message = "Region must match pattern 'xx-yyy' (e.g., 'us-ord')."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the LKE cluster"
  type        = string
  default     = "1.34" # Latest stable version, adjust as needed

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must be in the format 'X.Y' (e.g., '1.34')."
  }
}

variable "gpu_node_type" {
  description = "Linode instance type for GPU nodes (NVIDIA RTX 4000 Ada GPU x1 Small)"
  type        = string
  default     = "g2-gpu-rtx4000a1-s" # RTX4000 Ada x1 Small

  # Note: Check available GPU plans with: linode-cli linodes types --json | jq '.[] | select(.class=="gpu")'
}

variable "gpu_node_count" {
  description = "Number of GPU nodes in the cluster"
  type        = number
  default     = 1

  validation {
    condition     = var.gpu_node_count >= 1
    error_message = "gpu_node_count must be at least 1."
  }
}

variable "autoscaler_min" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 1

  validation {
    condition     = var.autoscaler_min >= 1
    error_message = "autoscaler_min must be at least 1."
  }
}

variable "autoscaler_max" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 5

  validation {
    condition     = var.autoscaler_max >= var.autoscaler_min
    error_message = "autoscaler_max must be greater than or equal to autoscaler_min."
  }
}

variable "ha_control_plane" {
  description = "Enable high availability for the control plane"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = ["lke", "gpu", "ml", "ai"]
}

variable "allowed_kubectl_ips" {
  description = "IP addresses allowed to access kubectl API"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Consider restricting this in production

  validation {
    condition     = alltrue([for ip in var.allowed_kubectl_ips : can(cidrhost(ip, 0))])
    error_message = "Each allowed_kubectl_ips entry must be a valid CIDR (e.g., '203.0.113.10/32')."
  }
}

variable "allowed_monitoring_ips" {
  description = "IP addresses allowed to access monitoring UIs (Grafana, Prometheus)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Consider restricting this in production

  validation {
    condition     = alltrue([for ip in var.allowed_monitoring_ips : can(cidrhost(ip, 0))])
    error_message = "Each allowed_monitoring_ips entry must be a valid CIDR (e.g., '203.0.113.10/32')."
  }
}

# GPU Operator Configuration
variable "install_gpu_operator" {
  description = "Install NVIDIA GPU Operator"
  type        = bool
  default     = true
}

variable "gpu_operator_version" {
  description = "Version of NVIDIA GPU Operator"
  type        = string
  default     = "v24.9.0"
}

variable "enable_gpu_monitoring" {
  description = "Enable GPU monitoring with DCGM exporter"
  type        = bool
  default     = true
}

# Metrics Server Configuration
variable "install_metrics_server" {
  description = "Install Kubernetes Metrics Server for resource metrics API"
  type        = bool
  default     = true
}

# Monitoring Stack Configuration
variable "install_monitoring" {
  description = "Install kube-prometheus-stack for comprehensive monitoring"
  type        = bool
  default     = true
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana (change in production)"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "15d"
}

variable "prometheus_storage_size" {
  description = "Prometheus persistent storage size"
  type        = string
  default     = "50Gi"
}

variable "grafana_storage_size" {
  description = "Grafana persistent storage size"
  type        = string
  default     = "10Gi"
}

# Cross-variable validation using modern precondition
resource "terraform_data" "validation_autoscaling" {
  lifecycle {
    precondition {
      condition     = var.autoscaler_min <= var.gpu_node_count && var.gpu_node_count <= var.autoscaler_max
      error_message = "gpu_node_count (${var.gpu_node_count}) must be between autoscaler_min (${var.autoscaler_min}) and autoscaler_max (${var.autoscaler_max})."
    }
  }
}
