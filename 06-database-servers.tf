
# create cloud config for nodes
data "cloudinit_config" "cloud_init_databases" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "setup-basic.sh"
    content_type = "text/x-shellscript"

    content = templatefile("./templates/setup-basic.tftpl", {
      "ssh_port"  = var.custom_ssh_port
      "user_name" = var.user_name
    })
  }

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = templatefile("./templates/database-cloud-init.tftpl", {
      "user_passwd" = var.user_passwd
      "user_name"   = var.user_name
    })
  }
}

# create posgresql server
resource "hcloud_server" "posgresql" {
  for_each           = var.postgresql_group
  name               = "${each.key}-${var.location}-${each.value.type}"
  image              = each.value.image
  server_type        = each.value.type
  location           = var.location
  placement_group_id = hcloud_placement_group.placement_cluster_databases.id

  ssh_keys = [
    hcloud_ssh_key.hetzner_nodes_key.id,
  ]
  user_data = data.cloudinit_config.cloud_init_databases.rendered

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  lifecycle {
    ignore_changes = all
  }

  connection {
    host        = self.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }

  labels = {
    "source" = "k8s"
    "type"   = "posgresql-node"
  }
}

resource "hcloud_server_network" "posgresql_network" {
  for_each  = var.postgresql_group
  server_id = hcloud_server.posgresql[each.key].id
  subnet_id = hcloud_network_subnet.private_network_subnet.id
}


# setup posgresql server
resource "null_resource" "init_posgresqls" {
  for_each = var.postgresql_group

  connection {
    bastion_host        = hcloud_server.entrance_server.ipv4_address
    bastion_port        = var.custom_ssh_port
    bastion_private_key = file(var.ssh_private_key_nodes)
    bastion_user        = var.user_name

    host        = hcloud_server_network.posgresql_network[each.key].ip
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "file" {
    source      = "scripts/setup-database.sh"
    destination = "/tmp/setup-database.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo PRIVATE_NETWORK_SUBNET_IP_RANGE=${var.private_network_subnet_ip_range} CLUSTER_LOCALE=${each.value.locale} bash /tmp/setup-database.sh",
    ]
  }
}

resource "null_resource" "post_init_posgresqls" {
  depends_on = [
    null_resource.init_posgresqls,
  ]

  for_each = {
    for key, value in var.postgresql_group : key => value
    if fileexists(value.post_setup_script_path)
  }

  connection {
    bastion_host        = hcloud_server.entrance_server.ipv4_address
    bastion_port        = var.custom_ssh_port
    bastion_private_key = file(var.ssh_private_key_nodes)
    bastion_user        = var.user_name

    host        = hcloud_server_network.posgresql_network[each.key].ip
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "file" {
    source      = each.value.post_setup_script_path
    destination = "/tmp/post_setup_script_path.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo PRIVATE_NETWORK_SUBNET_IP_RANGE=${var.private_network_subnet_ip_range} CLUSTER_LOCALE=${each.value.locale} bash /tmp/post_setup_script_path.sh",
    ]
  }
}

# resource "hcloud_firewall" "firewall_posgresqls" {
#   count = var.posgresql_count > 0 ? 1 : 0
#   name  = "firewall-posgresqls"

#   rule {
#     direction = "in"
#     protocol  = "icmp"
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }
#   rule {
#     direction = "in"
#     protocol  = "tcp"
#     port      = 10250
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }
#   rule {
#     direction = "in"
#     protocol  = "tcp"
#     port      = 4240
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }
#   rule {
#     direction = "in"
#     protocol  = "udp"
#     port      = 8472
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }
#   rule {
#     direction = "in"
#     protocol  = "tcp"
#     port      = "8080-8081"
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }
#   rule {
#     direction = "in"
#     protocol  = "tcp"
#     port      = "4244-4245"
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }
#   rule {
#     direction = "in"
#     protocol  = "udp"
#     port      = 53
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }
#   rule {
#     direction = "in"
#     protocol  = "tcp"
#     port      = "30000-32767"
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }
#   rule {
#     direction = "in"
#     protocol  = "tcp"
#     port      = 80
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }

#   rule {
#     direction = "in"
#     protocol  = "tcp"
#     port      = 443
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }

#   rule {
#     direction = "in"
#     protocol  = "tcp"
#     port      = var.custom_ssh_port
#     source_ips = [
#       "0.0.0.0/0",
#       "::/0"
#     ]
#   }
#   apply_to {
#     label_selector = "type in (posgresql-node)"
#   }
# }
