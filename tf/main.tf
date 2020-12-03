resource "google_container_cluster" "primary" {
  name               = "my-cluster"
  location           = var.zone
  remove_default_node_pool = true
  initial_node_count = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

  resource "google_container_node_pool" "primary_preemptible_nodes" {
    name       = "my-node-pool"
    location   = var.zone
    cluster    = google_container_cluster.primary.name
    node_count = 3

    management {
      auto_repair  = "true"
      auto_upgrade = "true"
    }

    node_config {
      preemptible     = true
      machine_type    = "g1-small"
      image_type      = "COS"
      disk_size_gb    = "30"
      disk_type       = "pd-standard"
      metadata        = {
        disable-legacy-endpoints = "true"
      }

      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }
  output "kubernetes_cluster_name" {
    value       = google_container_cluster.primary.name
    description = "GKE Cluster Name"
  }
