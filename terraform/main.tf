# main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

# The Kubernetes provider configuration for Terraform
# It connects to the GKE cluster using credentials from the GKE module's output.
provider "kubernetes" {
  host                   = "https://${module.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_cluster.ca_certificate)
}

# The Helm provider configuration for Terraform
# It uses the `kubernetes` argument to define how to connect to the GKE cluster.
provider "helm" {
  kubernetes = { # Corrected syntax: `kubernetes` is an argument, not a block.
    host                   = "https://${module.gke_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_cluster.ca_certificate)
  }
}

data "google_client_config" "default" {}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# --- GKE Cluster Module ---
module "gke_cluster" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "27.0.0"

  project_id        = var.gcp_project_id
  name              = var.cluster_name
  region            = var.gcp_region
  regional          = true

  ip_range_pods     = var.ip_range_pods
  ip_range_services = var.ip_range_services

  network         = google_compute_network.vpc_network.name
  subnetwork      = google_compute_subnetwork.gke_subnet.name

  release_channel = "REGULAR"

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-small"
      node_count         = 1
      auto_upgrade       = true
      auto_repair        = true
    }
  ]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.35.4"
  namespace  = "argocd"
  create_namespace = true
  timeout = 600
}

# Export the cluster details so we can use them later
output "cluster_name" {
  value = module.gke_cluster.name
}

output "cluster_endpoint" {
  value = module.gke_cluster.endpoint
}