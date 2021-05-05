provider "google" {
  credentials = file("terraform-key.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "new-terraform-network"
}
resource "google_compute_autoscaler" "foobar" {
  name   = "my-autoscaler"
  project = var.project
  zone   = "us-central1-c"
  target = google_compute_instance_group_manager.web-server-manager.self_link

  autoscaling_policy {
    max_replicas    = 7
    min_replicas    = 4
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_instance_template" "web-server-template" {
  name           = "my-instance-template"
  machine_type   = "n1-standard-1"
  can_ip_forward = false
  project = var.project
  tags = ["foo", "bar", "allow-lb-service"]

  disk {
    source_image = data.google_compute_image.centos_7.self_link
  }

  network_interface {
    network = "default"
  }

  metadata = {
    foo = "bar"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_target_pool" "web-servers" {
  name = "front-web-servers"
  project = var.project
  region = var.region
}

resource "google_compute_instance_group_manager" "web-server-manager" {
  name = "my-web-server-manager"
  zone = var.zone
  project = var.project
  version {
    instance_template  = google_compute_instance_template.web-server-template.self_link
    name               = "primary"
  }

  target_pools       = [google_compute_target_pool.web-servers.self_link]
  base_instance_name = "web"
}

data "google_compute_image" "centos_7" {
  family  = "centos-7"
  project = "centos-cloud"
}

module "lb" {
  source  = "GoogleCloudPlatform/lb/google"
  region       = var.region
  name         = "load-balancer-web-server"
  service_port = 80
  target_tags  = ["front-web-servers"]
  network      = module.network.network_name
}
