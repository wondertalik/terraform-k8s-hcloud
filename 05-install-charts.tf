resource "null_resource" "hccm" {
  depends_on = [
    null_resource.init_masters
  ]
  triggers = {
    hccm_version            = var.hccm_version
    hccm_custom_values_path = var.hccm_custom_values_path,
    master_count            = local.master_count,
  }

  count = var.hccm_enabled && local.master_count > 0 ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/hccm"
    ]
  }

  provisioner "file" {
    source      = "charts/hccm"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.hccm_custom_values_path
    destination = "charts/hccm/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "HCCM_VERSION=${var.hccm_version} K8S_HCLOUD_TOKEN=${var.k8s_hcloud_token} PRIVATE_NETWORK_ID=${hcloud_network.private_network.id} POD_NETWORK_CIDR=${var.pod_network_cidr} MASTER_COUNT=${local.master_count} bash charts/hccm/install.sh"
    ]
  }
}

resource "null_resource" "cilium" {
  depends_on = [
    null_resource.hccm,
  ]
  triggers = {
    cilium_version            = var.cilium_version
    cilium_custom_values_path = var.cilium_custom_values_path
  }
  count = var.cilium_enabled && local.master_count > 0 ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/cilium"
    ]
  }

  provisioner "file" {
    source      = "charts/cilium"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.cilium_custom_values_path
    destination = "charts/cilium/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "CILIUM_VERSION=${var.cilium_version} MASTER_COUNT=${local.master_count} RELAY_UI_ENABLED=${var.relay_ui_enabled} POD_NETWORK_CIDR=${var.pod_network_cidr} CONTROL_PLANE_ENDPOINT=${var.load_balancer_master_private_ip} KUBE_PROXY_REPLACEMENT=${var.cilium_kube_proxy_replacement} KUBERNETES_INGRESS_SUPPORT=${var.kubernetes_ingress_support} SHARED_INGRESS_MODE=${var.shared_ingress_mode} LOCATION=${var.location} INGRESS_LOAD_BALANCER_NAME=${var.ingress_load_balancer_name} INGRESS_LOAD_BALANCER_TYPE=${var.ingress_load_balancer_type}  bash charts/cilium/install.sh",
      "echo \"source <(cilium completion bash)\" >> .bashrc"
    ]
  }

}

resource "null_resource" "hcloud_csi" {
  depends_on = [null_resource.hccm]
  triggers = {
    hccm_version            = var.hccm_csi_version
    hccm_custom_values_path = var.hccm_csi_custom_values_path
  }
  count = var.hccm_enabled && var.hccm_csi_enabled && local.master_count > 0 ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/hcloud-csi"
    ]
  }

  provisioner "file" {
    source      = "charts/hcloud-csi"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.hccm_csi_custom_values_path
    destination = "charts/hcloud-csi/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "HCCM_CSI_VERSION=${var.hccm_csi_version} bash charts/hcloud-csi/install.sh"
    ]
  }
}

resource "null_resource" "metric_server" {
  depends_on = [
    null_resource.init_masters
  ]
  triggers = {
    metric_server_version            = var.metric_server_version
    metric_server_custom_values_path = var.metric_server_custom_values_path
  }
  count = var.metric_server_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/metrics-server"
    ]
  }

  provisioner "file" {
    source      = "charts/metrics-server"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.metric_server_custom_values_path
    destination = "charts/metrics-server/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "METRIC_SERVER_VERSION=${var.metric_server_version} bash charts/metrics-server/install.sh"
    ]
  }
}

resource "null_resource" "oauth2_proxy" {
  depends_on = [
    null_resource.init_ingreses,
    null_resource.init_masters,
  ]
  triggers = {
    oauth2_proxy_version            = var.oauth2_proxy_version
    oauth2_proxy_install            = var.oauth2_proxy_install
    oauth2_proxy_custom_values_path = var.oauth2_proxy_custom_values_path
  }
  count = var.oauth2_proxy_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/oauth2-proxy"
    ]
  }

  provisioner "file" {
    source      = "charts/oauth2-proxy"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.oauth2_proxy_custom_values_path
    destination = "charts/oauth2-proxy/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "OAUTH2_PROXY_VERSION=${var.oauth2_proxy_version} OAUTH2_PROXY_INSTALL=${var.oauth2_proxy_install} bash charts/oauth2-proxy/install.sh"
    ]
  }
}

resource "null_resource" "ingress_nginx" {
  depends_on = [
    null_resource.init_ingreses,
  ]
  triggers = {
    ingress_version            = var.ingress_version
    ingress_custom_values_path = var.ingress_custom_values_path
    ingress_server_ids         = join(",", values(hcloud_server.ingress)[*].id)
  }
  count = var.ingress_enabled && local.ingress_count > 0 ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/ingress-nginx",
    ]
  }

  provisioner "file" {
    source      = "charts/ingress-nginx"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.ingress_custom_values_path
    destination = "charts/ingress-nginx/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "INGRESS_VERSION=${var.ingress_version} LOCATION=${var.location} INGRESS_LOAD_BALANCER_NAME=${var.ingress_load_balancer_name} INGRESS_LOAD_BALANCER_TYPE=${var.ingress_load_balancer_type}  NODE_NAMES=${join(",", values(hcloud_server.ingress)[*].name)} NODE_COUNT=${local.ingress_count} bash charts/ingress-nginx/install.sh"
    ]
  }
}

resource "null_resource" "cert_manager" {
  depends_on = [
    null_resource.init_masters,
    null_resource.cilium
  ]
  triggers = {
    cert_manager_version            = var.cert_manager_version
    cert_manager_custom_values_path = var.cert_manager_custom_values_path
  }
  count = var.cert_manager_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p charts"]
  }

  provisioner "remote-exec" {
    inline = ["rm -rf charts/cert-manager"]
  }

  provisioner "file" {
    source      = "charts/cert-manager"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.cert_manager_custom_values_path
    destination = "charts/cert-manager/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "CERT_MANAGER_VERSION=${var.cert_manager_version} ACME_EMAIL=${var.cert_manager_acme_email} bash charts/cert-manager/install.sh"
    ]
  }
}

resource "null_resource" "kube-prometheus-stack" {
  depends_on = [
    null_resource.init_masters
  ]
  triggers = {
    kube_prometheus_stack_version            = var.kube_prometheus_stack_version
    kube_prometheus_stack_install            = var.kube_prometheus_stack_install
    kube_prometheus_stack_custom_values_path = var.kube_prometheus_stack_custom_values_path
  }
  count = var.kube_prometheus_stack_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/kube-prometheus-stack"
    ]
  }

  provisioner "file" {
    source      = "charts/kube-prometheus-stack"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.kube_prometheus_stack_custom_values_path
    destination = "charts/kube-prometheus-stack/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "KUBE_PROMETHEUS_STACK_VERSION=${var.kube_prometheus_stack_version} KUBE_PROMETHEUS_STACK_INSTALL=${var.kube_prometheus_stack_install} GRAFANA_ADMIN_PASSWORD=${var.grafana_admin_password} bash charts/kube-prometheus-stack/install.sh"
    ]
  }
}

resource "null_resource" "loki" {
  depends_on = [
    null_resource.init_masters
  ]
  triggers = {
    loki_version            = var.loki_version
    loki_install            = var.loki_install
    loki_custom_values_path = var.loki_custom_values_path
  }
  count = var.loki_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/loki"
    ]
  }

  provisioner "file" {
    source      = "charts/loki"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.loki_custom_values_path
    destination = "charts/loki/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "LOKI_VERSION=${var.loki_version} LOKI_INSTALL=${var.loki_install} bash charts/loki/install.sh"
    ]
  }
}

resource "null_resource" "promtail" {
  depends_on = [
    null_resource.init_masters
  ]
  triggers = {
    promtail_version            = var.promtail_version
    promtail_install            = var.promtail_install
    promtail_custom_values_path = var.promtail_custom_values_path
  }
  count = var.promtail_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/promtail"
    ]
  }

  provisioner "file" {
    source      = "charts/promtail"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.promtail_custom_values_path
    destination = "charts/promtail/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "PROMTAIL_VERSION=${var.promtail_version} PROMTAIL_INSTALL=${var.promtail_install} bash charts/promtail/install.sh"
    ]
  }
}

resource "null_resource" "jaeger" {
  depends_on = [
    null_resource.init_masters,
    null_resource.cert_manager
  ]
  triggers = {
    seq_version    = var.jaeger_version
    jaeger_install = var.jaeger_install
  }
  count = var.jaeger_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/jaeger"
    ]
  }

  provisioner "file" {
    source      = "charts/jaeger"
    destination = "charts"
  }

  provisioner "remote-exec" {
    inline = [
      "JAEGER_VERSION=${var.jaeger_version} JAEGER_INSTALL=${var.jaeger_install} bash charts/jaeger/install.sh"
    ]
  }
}

resource "null_resource" "seq" {
  depends_on = [
    null_resource.init_masters
  ]
  triggers = {
    seq_version            = var.seq_version
    seq_install            = var.seq_install
    seq_custom_values_path = var.seq_custom_values_path
  }
  count = var.seq_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/seq"
    ]
  }

  provisioner "file" {
    source      = "charts/seq"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.seq_custom_values_path
    destination = "charts/seq/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "SEQ_VERSION=${var.seq_version} SEQ_INSTALL=${var.seq_install} bash charts/seq/install.sh"
    ]
  }
}

resource "null_resource" "rabbitmq" {
  depends_on = [
    null_resource.init_masters
  ]
  triggers = {
    rabbitmq_version            = var.rabbitmq_version
    rabbitmq_install            = var.rabbitmq_install
    rabbitmq_custom_values_path = var.rabbitmq_custom_values_path
  }
  count = var.rabbitmq_enabled ? 1 : 0

  connection {
    host        = hcloud_server.entrance_server.ipv4_address
    port        = var.custom_ssh_port
    type        = "ssh"
    private_key = file(var.ssh_private_key_entrance)
    user        = var.user_name
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p charts",
      "rm -rf charts/rabbitmq"
    ]
  }

  provisioner "file" {
    source      = "charts/rabbitmq"
    destination = "charts"
  }

  provisioner "file" {
    on_failure  = continue
    source      = var.rabbitmq_custom_values_path
    destination = "charts/rabbitmq/values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "RABBITMQ_VERSION=${var.rabbitmq_version} RABBITMQ_INSTALL=${var.rabbitmq_install} bash charts/rabbitmq/install.sh"
    ]
  }
}


resource "null_resource" "post_restart_masters" {
  depends_on = [
    null_resource.cilium,
    null_resource.hccm
  ]
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

  provisioner "remote-exec" {
    inline = ["sudo systemctl daemon-reload && sudo systemctl restart kubelet"]
  }
}

resource "null_resource" "post_restart_workers" {
  depends_on = [
    null_resource.cilium,
    null_resource.hccm
  ]
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

  provisioner "remote-exec" {
    inline = ["sudo systemctl daemon-reload && sudo systemctl restart kubelet"]
  }
}

resource "null_resource" "post_restart_ingresses" {
  depends_on = [
    null_resource.cilium,
    null_resource.hccm
  ]
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

  provisioner "remote-exec" {
    inline = ["sudo systemctl daemon-reload && sudo systemctl restart kubelet"]
  }
}


