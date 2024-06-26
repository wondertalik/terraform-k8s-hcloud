output "entrance_ips" {
  value = [hcloud_server.entrance_server[*].ipv4_address]
}

output "master_ips" {
  value = values(hcloud_server.master)[*].ipv4_address
}

output "worker_group_1_ips" {
  value = values(hcloud_server.worker_group_1)[*].ipv4_address
}

output "ingresses_ips" {
  value = values(hcloud_server.ingress)[*].ipv4_address
}

output "database_ips" {
  value = values(hcloud_server.posgresql)[*].ipv4_address
}

output "asset_ips" {
  value = values(hcloud_server.asset)[*].ipv4_address
}

output "network_id" {
  value = [hcloud_network.private_network.id]
}

output "subnet_network_id" {
  value = [hcloud_network_subnet.private_network_subnet.id]
}

output "kube_prometheus_stack_version" {
  value = [var.kube_prometheus_stack_version]
}

output "cert_manager_version" {
  value = [var.cert_manager_version]
}

output "promtail_version" {
  value = [var.promtail_version]
}

output "loki_version" {
  value = [var.loki_version]
}

output "metric_server_version" {
  value = [var.metric_server_version]
}

output "hccm_version" {
  value = [var.hccm_version]
}

output "ingress_version" {
  value = [var.ingress_version]
}

output "cilium_version" {
  value = [var.cilium_version]
}

output "oauth2_proxy_version" {
  value = [var.oauth2_proxy_version]
}
