# variables.tf

variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name for the GKE cluster"
  type        = string
  default     = "my-python-app-cluster"
}

# New variables for the GKE module
variable "ip_range_pods" {
  description = "The name of the secondary range for pods."
  type        = string
  default     = "gke-pods-range"
}

variable "ip_range_services" {
  description = "The name of the secondary range for services."
  type        = string
  default     = "gke-services-range"
}