# terraform/network.tf

# Create a new VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "my-python-app-vpc"
  auto_create_subnetworks = false # We will create subnets manually
}

# Create a subnetwork with secondary ranges for the GKE cluster
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "my-python-app-subnet"
  ip_cidr_range = "10.0.0.0/16" # Example primary IP range
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id

  # Secondary IP range for Pods
  secondary_ip_range {
    range_name    = var.ip_range_pods
    ip_cidr_range = "10.1.0.0/20"
  }

  # Secondary IP range for Services
  secondary_ip_range {
    range_name    = var.ip_range_services
    ip_cidr_range = "10.2.0.0/20"
  }
}