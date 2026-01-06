provider "google" {
  project = "project-e2a4c0c6-d515-440a-abd"
  region  = "europe-central2"
  zone    = "europe-central2-a"
}

# Włączamy niezbędne API
resource "google_project_service" "container" {
  service = "container.googleapis.com"
  disable_on_destroy = false
}

# Tworzymy klaster GKE
resource "google_container_cluster" "primary" {
  name     = "devops-cluster"
  location = "europe-central2-a"  # Klaster strefowy (tańszy niż regionalny)
  
  # Usuwamy domyślną pulę węzłów po utworzeniu klastra
  remove_default_node_pool = true
  initial_node_count       = 1

  # Wyłączamy basic auth i certyfikat klienta (zalecane)
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  depends_on = [google_project_service.container]
}

# Tworzymy dedykowaną pulę węzłów
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "europe-central2-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1  # Tylko 1 węzeł dla oszczędności

  node_config {
    preemptible  = true        # Maszyny preemptible są znacznie tańsze!
    machine_type = "e2-medium" # 2 vCPU, 4GB RAM

    # Uprawnienia OAuth dla węzłów
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
