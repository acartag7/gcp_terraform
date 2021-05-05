provider "google" {
  credentials = file("terraform-key.json")
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
  name                    = "terraform-instance"
  metadata_startup_script = file("startup.sh")
  machine_type            = "f1-micro"
  tags                    = ["web"]
  zone                    = var.zone

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
    network = default
    access_config {
    }
  }
}

