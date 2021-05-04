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

module "network_fabric-net-firewall" {
    source = "terraform-google-modules/network/google//modules/fabric-net-firewall"
    project_id = var.project
    network = module.network.network_name
    internal_ranges_enabled = true
    internal_ranges = "10.0.0.0/16"
}