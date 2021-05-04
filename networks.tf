module "network" {
  source       = "terraform-google-modules/network/google"
  network_name = "main-deployment-network"
  project_id   = var.project

  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = var.cidr
      subnet_region = var.region
    },
  ]
  secondary_ranges = {
    subnet-01 = []
  }
}

module "network_routes" {
  source     = "terraform-google-modules/network/google//modules/routes"
  project_id = var.project
  network    = module.network.network_name

  routes = [
    {
      name              = "egress-internet"
      description       = "Route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}

module "network_fabric-net-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.project
  network                 = module.network.network_name
  internal_ranges_enabled = true
  internal_ranges         = ["10.0.0.0/16"]
}
