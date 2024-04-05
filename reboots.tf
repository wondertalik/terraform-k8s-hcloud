resource "null_resource" "reboot_now_master_group" {
  for_each = var.reboot_servers ? var.master_group : {}
  triggers = {
    reboot_servers = var.reboot_servers
  }

  connection {
    bastion_host        = hcloud_server.entrance_server.ipv4_address
    bastion_port        = var.custom_ssh_port
    bastion_private_key = file(var.ssh_private_key_nodes)
    bastion_user        = var.user_name

    host        = hcloud_server_network.master_network[each.key].ip
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["sudo shutdown -r +0"]
  }
}

resource "null_resource" "reboot_now_worker_group_1" {
  for_each = var.reboot_servers ? var.worker_group_1 : {}

  triggers = {
    reboot_servers = var.reboot_servers
  }

  connection {
    bastion_host        = hcloud_server.entrance_server.ipv4_address
    bastion_port        = var.custom_ssh_port
    bastion_private_key = file(var.ssh_private_key_nodes)
    bastion_user        = var.user_name

    host        = hcloud_server_network.worker_group_1_network[each.key].ip
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["sudo shutdown -r +0"]
  }
}

resource "null_resource" "reboot_now_asset_group" {
  for_each = var.reboot_servers ? var.asset_group : {}

  connection {
    bastion_host        = hcloud_server.entrance_server.ipv4_address
    bastion_port        = var.custom_ssh_port
    bastion_private_key = file(var.ssh_private_key_nodes)
    bastion_user        = var.user_name

    host        = hcloud_server_network.asset_network[each.key].ip
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["sudo shutdown -r +0"]
  }
}

resource "null_resource" "reboot_now_ingress_group" {
  for_each = var.reboot_servers ? var.ingress_group : {}
  triggers = {
    reboot_servers = var.reboot_servers
  }

  connection {
    bastion_host        = hcloud_server.entrance_server.ipv4_address
    bastion_port        = var.custom_ssh_port
    bastion_private_key = file(var.ssh_private_key_nodes)
    bastion_user        = var.user_name

    host        = hcloud_server_network.ingress_network[each.key].ip
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["sudo shutdown -r +0"]
  }
}


resource "null_resource" "reboot_now_posgresql" {
  for_each = var.reboot_servers ? var.postgresql_group : {}

  triggers = {
    reboot_servers = var.reboot_servers
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

  provisioner "remote-exec" {
    inline = ["sudo shutdown -r +0"]
  }
}
