provider "google" {
  credentials = "terraform-key.json"
  project     = var.project
  region      = var.region
  zone        = var.zone
}

terraform {
  backend "gcs" {
    bucket      = "terraform_state_0504"
    prefix      = "Terraform-Info"
    credentials = "terraform-key.json"
  }
}
resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network = module.network.network_name
    access_config {
    }
  }
}

