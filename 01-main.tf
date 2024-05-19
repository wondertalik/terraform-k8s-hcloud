provider "hcloud" {
  token = var.hcloud_token
}

locals {
  master_count  = length(var.master_group)
  worker_count  = length(var.worker_group_1)
  ingress_count = length(var.ingress_group)
  asset_count   = length(var.asset_group)
  master_keys   = keys(var.master_group)
}

# create ssh-key for entrance
resource "hcloud_ssh_key" "hetzner_entrance_key" {
  name       = var.ssh_private_key_entrance_hcloud
  public_key = file(var.ssh_public_key_entrance)
}

# create ssh-key for nodes
resource "hcloud_ssh_key" "hetzner_nodes_key" {
  name       = var.ssh_private_key_nodes_hcloud
  public_key = file(var.ssh_public_key_nodes)
}

# create placement group
resource "hcloud_placement_group" "placement_cluster_masters_1" {
  count = local.master_count > 0 ? 1 : 0
  name  = "placement-masters-1"
  type  = "spread"
  labels = {
    "source" = "k8s"
  }
}

resource "hcloud_placement_group" "placement_worker_group_1" {
  count = local.worker_count > 0 ? 1 : 0
  name  = "placement-workers-1"
  type  = "spread"
  labels = {
    "source"       = "k8s"
    "group_number" = "g1"
  }
}

resource "hcloud_placement_group" "placement_cluster_databases" {
  name = "placement-databases-1"
  type = "spread"
  labels = {
    "source" = "k8s"
  }
}

resource "hcloud_placement_group" "placement_cluster_others_1" {
  name = "placement-others-1"
  type = "spread"
  labels = {
    "source" = "k8s"
  }
}

resource "hcloud_placement_group" "placement_cluster_ingresses_1" {
  count = local.ingress_count > 0 ? 1 : 0
  name  = "placement-ingresses-1"
  type  = "spread"
  labels = {
    "source" = "k8s"
  }
}

# create private network
resource "hcloud_network" "private_network" {
  name              = "k8s-private-network"
  ip_range          = var.private_network_ip_range
  delete_protection = false
  labels = {
    "type" : "k8s-private-network",
    "source" = "k8s"
  }
}

resource "hcloud_network_subnet" "private_network_subnet" {
  network_id   = hcloud_network.private_network.id
  type         = "server"
  network_zone = var.network_zone
  ip_range     = var.private_network_subnet_ip_range
}

resource "hcloud_load_balancer" "master_load_balancer" {
  name               = "load-balancer-masters"
  load_balancer_type = var.master_load_balancer_type
  location           = var.location

  labels = {
    "type" = "load-balancer-masters"
  }
}

resource "hcloud_load_balancer_network" "master_load_balancer_network" {
  depends_on = [
    hcloud_network_subnet.private_network_subnet
  ]
  load_balancer_id        = hcloud_load_balancer.master_load_balancer.id
  subnet_id               = hcloud_network_subnet.private_network_subnet.id
  enable_public_interface = false
  ip                      = var.load_balancer_master_private_ip
}

resource "hcloud_load_balancer_target" "master_load_balancer_target" {
  depends_on = [
    hcloud_load_balancer_network.master_load_balancer_network
  ]
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.master_load_balancer.id
  label_selector   = "type=master-node"
  use_private_ip   = true
}

resource "hcloud_load_balancer_service" "master_load_balancer_service" {
  load_balancer_id = hcloud_load_balancer.master_load_balancer.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
}
