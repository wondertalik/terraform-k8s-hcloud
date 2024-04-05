resource "null_resource" "pre_init_masters" {
  for_each = var.master_group

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

resource "null_resource" "init_main_master" {
  count = local.master_count > 0 ? 1 : 0
  depends_on = [
    null_resource.pre_init_masters
  ]

  connection {
    host        = hcloud_server.master[local.master_keys[0]].ipv4_address
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
    source      = "scripts/kube-main-master.sh"
    destination = "scripts/kube-main-master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "SSH_USERNAME=${var.user_name} POD_NETWORK_CIDR=${var.pod_network_cidr} CONTROL_PLANE_ENDPOINT=${var.load_balancer_master_private_ip} CLUSTER_NAME=${var.cluster_name} bash ./scripts/kube-main-master.sh"
    ]
  }

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/secrets && touch ${path.module}/secrets/kubeadm_control_plane_join && touch ${path.module}/secrets/kubeadm_join && touch ${path.module}/secrets/kubeadm_config"
  }

  provisioner "local-exec" {
    command = "bash scripts/copy-kubeadm-secrets.sh"

    environment = {
      SSH_PRIVATE_KEY = var.ssh_private_key_nodes
      SSH_USERNAME    = var.user_name
      SSH_PORT        = var.custom_ssh_port
      SSH_HOST        = hcloud_server.master[local.master_keys[0]].ipv4_address
      TARGET          = "${path.module}/secrets/"
    }
  }

  provisioner "file" {
    connection {
      host        = hcloud_server.entrance_server.ipv4_address
      port        = var.custom_ssh_port
      type        = "ssh"
      private_key = file(var.ssh_private_key_nodes)
      user        = var.user_name
    }
    source      = "secrets/kubeadm_config"
    destination = ".kube/config"
  }

  provisioner "remote-exec" {
    connection {
      host        = hcloud_server.entrance_server.ipv4_address
      port        = var.custom_ssh_port
      type        = "ssh"
      private_key = file(var.ssh_private_key_nodes)
      user        = var.user_name
    }
    inline = [
      "chmod 600 .kube/config",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/kubeadm",
      "rm -rf scripts"
    ]
  }
}

resource "null_resource" "init_masters" {
  depends_on = [
    null_resource.init_main_master,
    null_resource.pre_init_masters
  ]

  count = local.master_count
  connection {
    host        = hcloud_server.master[local.master_keys[count.index]].ipv4_address
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
    source      = "scripts/kube-master.sh"
    destination = "scripts/kube-master.sh"
  }

  provisioner "file" {
    source      = "${path.module}/secrets/kubeadm_control_plane_join"
    destination = "/tmp/kubeadm_control_plane_join"
  }

  provisioner "remote-exec" {
    inline = ["MASTER_INDEX=${count.index} bash scripts/kube-master.sh"]
  }

  provisioner "remote-exec" {
    inline = [
      "rm /tmp/kubeadm_control_plane_join",
      "rm -rf scripts"
    ]
  }

}

resource "null_resource" "pre_init_workers" {
  for_each = var.worker_group_1

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

resource "null_resource" "init_workers" {
  depends_on = [
    null_resource.init_masters,
    null_resource.pre_init_workers
  ]
  for_each = var.worker_group_1
  connection {
    host        = hcloud_server.worker_group_1[each.key].ipv4_address
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

resource "null_resource" "pre_init_ingresses" {
  for_each = var.ingress_group

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

resource "null_resource" "init_ingreses" {
  depends_on = [
    null_resource.init_masters,
    null_resource.pre_init_ingresses
  ]
  for_each = var.ingress_group
  connection {
    host        = hcloud_server.ingress[each.key].ipv4_address
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
