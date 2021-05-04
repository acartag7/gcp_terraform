provider "google" {
    credentials = "terraform-key.json"

    project = "playground-s-11-d8f0bc2e"
    region = "us-central1"
    zone = "us-central-c"  
}

resource "google_compute_network" "vpc_network" {
    name = "main-deployment-network"
}

terraform {
    backend "gcs" {
        bucket = "terraform_state_0504"
        prefix = "Terraform-Info"
    }
}