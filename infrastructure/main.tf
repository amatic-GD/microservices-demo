terraform {
  backend "gcs" {
    bucket =  "amatic"
    prefix = "terraform/state"
  }
}
provider "google" {
project = var.project_id
region = var.region
}

#Dev environment configuration
resource "google_compute_network" "amatic-dev-vpc" {
name = "amatic-dev-vpc"
auto_create_subnetworks = false

routing_mode = "GLOBAL"

}

resource "google_compute_subnetwork" "amatic_dev_public_subnet" {
name = "amatic-dev-public-subnet"
ip_cidr_range = var.dev_public_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-dev-vpc.self_link
private_ip_google_access = false
}

resource "google_compute_subnetwork" "amatic_dev_private_subnet" {
name = "amatic-dev-private-subnet"
ip_cidr_range = var.dev_private_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-dev-vpc.self_link
private_ip_google_access = true
}

resource "google_container_cluster" "amatic_dev_cluster" {
  name     = "amatic-dev"
  location = var.region
  project  = var.project_id

  node_pool {
    name       = "dev-node-pool"
    node_count = 1

    node_config {
      machine_type = "n1-standard-2"
    }
  }
}

#End of dev environment configuration

#Staging environment configuration
resource "google_compute_network" "amatic-stage-vpc" {
name = "amatic-stage-vpc"
auto_create_subnetworks = false

routing_mode = "GLOBAL"

}

resource "google_compute_subnetwork" "amatic_stage_public_subnet" {
name = "amatic-stage-public-subnet"
ip_cidr_range = var.stage_public_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-stage-vpc.self_link
private_ip_google_access = false
}

resource "google_compute_subnetwork" "amatic_stage_private_subnet" {
name = "amatic-stage-private-subnet"
ip_cidr_range = var.stage_private_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-stage-vpc.self_link
private_ip_google_access = true
}

resource "google_container_cluster" "amatic_stage_cluster" {
  name     = "amatic-stage"
  location = var.region
  project  = var.project_id

  node_pool {
    name       = "stage-node-pool"
    node_count = 1

    node_config {
      machine_type = "n1-standard-2"
    }
  }
}

#End of staging environment configuration

#Production environment configuration

resource "google_compute_network" "amatic-prod-vpc" {
name = "amatic-prod-vpc"
auto_create_subnetworks = false

routing_mode = "GLOBAL"

}

resource "google_compute_subnetwork" "amatic_prod_public_subnet" {
name = "amatic-prod-public-subnet"
ip_cidr_range = var.prod_public_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-prod-vpc.self_link
private_ip_google_access = false
}

resource "google_compute_subnetwork" "amatic_prod_private_subnet" {
name = "amatic-prod-private-subnet"
ip_cidr_range = var.prod_private_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-prod-vpc.self_link
private_ip_google_access = true
}

resource "google_container_cluster" "amatic_prod_cluster" {
  name     = "amatic-prod"
  location = var.region
  project  = var.project_id

  node_pool {
    name       = "prod-node-pool"
    initial_node_count = 3
    autoscaling {
      min_node_count = 3
      max_node_count = 10
    }

    node_config {
      machine_type = "n1-standard-4"  
      disk_size_gb = 100              
      preemptible  = false            
    }
  }

  network_policy {
    enabled = true 
  }

  logging_service = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

}

#End of production environment configuration
resource "google_storage_bucket" "amatic_bucket" {
  name          = "amatic"
  location      = "EUROPE-WEST2" 
  force_destroy = true
}