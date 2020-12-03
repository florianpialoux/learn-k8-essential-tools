variable "project_id" {
  description = "project id"
}

variable "zone" {
  description = "zone"
}

provider "google" {
  credentials = file("florian-test-297317-579f4bd03967.json")
  project = var.project_id
  region  = var.zone
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.zone
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"

}

output "zone" {
  value       = var.zone
  description = "zone"
}
