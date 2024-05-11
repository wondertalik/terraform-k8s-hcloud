
# create cloud config for nodes
data "cloudinit_config" "cloud_init_assets" {
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
    filename     = "setup-node.sh"
    content_type = "text/x-shellscript"

    content = replace(
      replace(
        file("./scripts/setup-node.sh"),
        "[kubernetes-version]", var.kubernetes_version
      ),
      "[kubernetes-major-version]", regex("([0-9]+\\.[0-9]+)\\.([0-9]+)", var.kubernetes_version)[0]
    )
  }

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = templatefile("./templates/node-cloud-init.tftpl", {
      "user_passwd" = var.user_passwd
      "user_name"   = var.user_name
    })
  }
}


# create asset servers
resource "hcloud_server" "asset" {
  for_each           = var.asset_group
  name               = "${each.key}-${var.location}-${each.value.type}"
  image              = var.asset_image
  server_type        = each.value.type
  location           = var.location
  placement_group_id = hcloud_placement_group.placement_cluster_others_1.id

  ssh_keys = [
    hcloud_ssh_key.hetzner_nodes_key.id,
  ]
  user_data = data.cloudinit_config.cloud_init_assets.rendered

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
    "type"   = "asset-node"
  }
}

resource "hcloud_server_network" "asset_network" {
  depends_on = [
    hcloud_load_balancer_network.master_load_balancer_network
  ]
  for_each  = var.asset_group
  server_id = hcloud_server.asset[each.key].id
  subnet_id = hcloud_network_subnet.private_network_subnet.id
}

resource "null_resource" "pre_init_assets" {
  for_each = var.asset_group

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

  provisioner "file" {
    source      = "scripts/pre_init_config.sh"
    destination = "/tmp/pre_init_config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /tmp/pre_init_config.sh"
    ]
  }
}

resource "null_resource" "init_assets" {
  depends_on = [
    null_resource.init_masters,
    null_resource.pre_init_assets
  ]
  for_each = var.asset_group
  connection {
    host        = hcloud_server.asset[each.key].ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_nodes)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p scripts"
    ]
  }

  provisioner "file" {
    source      = "scripts/kube-node.sh"
    destination = "scripts/kube-node.sh"
  }

  provisioner "file" {
    source      = "${path.module}/secrets/kubeadm_join"
    destination = "/tmp/kubeadm_join"
  }

  provisioner "remote-exec" {
    inline = ["bash scripts/kube-node.sh"]
  }

  provisioner "remote-exec" {
    inline = [
      "rm /tmp/kubeadm_join",
      "rm -rf scripts"
    ]
  }

}

resource "null_resource" "post_init_assets" {
  depends_on = [
    null_resource.init_assets,
    null_resource.cilium
  ]

  triggers = {
    asset_count = local.asset_count
  }

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "file" {
    source      = "scripts/configure-assets.sh"
    destination = "/tmp/configure-assets.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/configure-assets.sh",
    ]
  }
}
