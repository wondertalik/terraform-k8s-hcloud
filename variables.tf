variable "hcloud_token" {
  type      = string
  sensitive = true # Requires terraform >= 0.14
}

variable "k8s_hcloud_token" {
  type      = string
  sensitive = true # Requires terraform >= 0.14
}

variable "user_name" {
  type = string
}

variable "user_passwd" {
  type      = string
  sensitive = true # Requires terraform >= 0.14
}

variable "cluster_name" {
  type    = string
  default = "kubernetes"
}

variable "entrance_type" {
  type        = string
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = "cx11"
}

variable "master_group" {
  type = map(object({
    type = string
  }))
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = {}
}

variable "ingress_group" {
  type = map(object({
    type = string
  }))
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = {}
}


variable "asset_group" {
  type = map(object({
    type = string
  }))
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = {}
}

variable "worker_group_1" {
  type = map(object({
    type = string
  }))
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = {}
}

variable "postgresql_group" {
  type = map(object({
    type                   = string,
    image                  = string,
    post_setup_script_path = string,
    locale                 = string
  }))
  description = "For more types have a look at https://www.hetzner.de/cloud"
  default     = {}
}

variable "network_zone" {
  type        = string
  description = "Predefined network zone"
  default     = "eu-central"
}

variable "location" {
  type        = string
  description = "Predefined location"
  default     = "nbg1"
}

variable "entrance_image" {
  type        = string
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-22.04"
}

variable "master_image" {
  type        = string
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-22.04"
}

variable "worker_image" {
  type        = string
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-22.04"
}

variable "ingress_image" {
  type        = string
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-22.04"
}

variable "asset_image" {
  type        = string
  description = "Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04, ubuntu-18.04)"
  default     = "ubuntu-22.04"
}

variable "ssh_private_key_entrance_hcloud" {
  type        = string
  description = "Name of the ssh key in hcloud for entrance"
  default     = "id_hetzner_entrance"
}

variable "ssh_private_key_entrance" {
  type        = string
  description = "Private Key to authorized the access for the entrance server"
}

variable "ssh_public_key_entrance" {
  type        = string
  description = "Public Key to authorized the access for the entrance server"
}

variable "ssh_private_key_nodes_hcloud" {
  type        = string
  description = "Name of the ssh key in hcloud for the machines"
  default     = "key_hetzner_nodes"
}

variable "ssh_private_key_nodes" {
  type        = string
  description = "Private Key to access the machines"
}

variable "ssh_public_key_nodes" {
  type        = string
  description = "Public Key to authorized the access for the machines"
}

variable "private_network_ip_range" {
  type        = string
  description = "IP range of private network"
  default     = "10.0.0.0/16"
}

variable "private_network_subnet_ip_range" {
  type        = string
  description = "IP range of private sub network"
  default     = "10.0.1.0/24"
}

variable "load_balancer_master_private_ip" {
  type    = string
  default = "10.0.1.2"
}

variable "master_load_balancer_type" {
  type    = string
  default = "lb11"
}

variable "ingress_load_balancer_type" {
  type    = string
  default = "lb11"
}

variable "ingress_load_balancer_name" {
  type    = string
  default = "load-balancer-ingreses"
}

variable "pod_network_cidr" {
  type    = string
  default = "10.0.16.0/20"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29.3"
}

variable "custom_ssh_port" {
  type    = number
  default = 29351
}

variable "kubernetes_ingress_support" {
  type    = bool
  default = false
}

variable "shared_ingress_mode" {
  type    = bool
  default = true
}

variable "ingress_enabled" {
  type    = bool
  default = true
}

variable "ingress_custom_values_path" {
  type    = string
  default = ""
}


variable "ingress_version" {
  type    = string
  default = "4.10.1"
}

variable "oauth2_proxy_enabled" {
  type    = bool
  default = false
}

variable "oauth2_proxy_install" {
  type    = bool
  default = false
}

variable "oauth2_proxy_custom_values_path" {
  type    = string
  default = ""
}

variable "oauth2_proxy_version" {
  type    = string
  default = "7.5.3"
}

variable "cilium_enabled" {
  type    = bool
  default = true
}

variable "cilium_version" {
  type    = string
  default = "1.15.4"
}


variable "cilium_custom_values_path" {
  type    = string
  default = ""
}

variable "cilium_kube_proxy_replacement" {
  type    = bool
  default = false
}

variable "hccm_enabled" {
  type    = bool
  default = true
}

variable "hccm_version" {
  type    = string
  default = "1.19.0"
}

variable "hccm_custom_values_path" {
  type    = string
  default = ""
}

variable "hccm_csi_enabled" {
  type    = bool
  default = false
}

variable "hccm_csi_version" {
  type    = string
  default = "2.6.0"
}

variable "hccm_csi_custom_values_path" {
  type    = string
  default = ""
}

variable "metric_server_enabled" {
  type    = bool
  default = false
}

variable "metric_server_version" {
  type    = string
  default = "3.12.1"
}

variable "metric_server_custom_values_path" {
  type    = string
  default = ""
}

variable "cert_manager_enabled" {
  type    = bool
  default = true
}

variable "cert_manager_version" {
  type    = string
  default = "1.14.5"
}

variable "cert_manager_custom_values_path" {
  type    = string
  default = ""
}

variable "cert_manager_acme_email" {
  type = string
}

variable "relay_ui_enabled" {
  type    = bool
  default = false
}

variable "kube_prometheus_stack_enabled" {
  type    = bool
  default = false
}

variable "kube_prometheus_stack_install" {
  type    = bool
  default = false
}

variable "kube_prometheus_stack_custom_values_path" {
  type    = string
  default = ""
}

variable "kube_prometheus_stack_version" {
  type    = string
  default = "58.3.3"
}

variable "grafana_admin_password" {
  type    = string
  default = "prom-operator"
}

variable "loki_enabled" {
  type    = bool
  default = false
}

variable "loki_install" {
  type    = bool
  default = false
}

variable "loki_custom_values_path" {
  type    = string
  default = ""
}

variable "loki_version" {
  type    = string
  default = "5.5.2"
}

variable "promtail_enabled" {
  type    = bool
  default = false
}

variable "promtail_install" {
  type    = bool
  default = false
}

variable "promtail_custom_values_path" {
  type    = string
  default = ""
}

variable "promtail_version" {
  type    = string
  default = "6.1.2"
}

variable "seq_version" {
  type    = string
  default = "2024.2.1"
}

variable "seq_enabled" {
  type    = bool
  default = false
}

variable "seq_install" {
  type    = bool
  default = false
}

variable "seq_custom_values_path" {
  type    = string
  default = ""
}

variable "jaeger_version" {
  type    = string
  default = "1.56"
}

variable "jaeger_enabled" {
  type    = bool
  default = false
}

variable "jaeger_install" {
  type    = bool
  default = false
}

variable "rabbitmq_version" {
  type    = string
  default = "2.6.0"
}

variable "rabbitmq_enabled" {
  type    = bool
  default = false
}

variable "rabbitmq_install" {
  type    = bool
  default = false
}

variable "rabbitmq_custom_values_path" {
  type    = string
  default = ""
}

variable "reboot_servers" {
  type    = bool
  default = false
}
