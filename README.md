# Terraform Kubernetes on Hetzner Cloud

This repository will help to set up a Kubernetes Cluster with [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/) on [Hetzner Cloud](https://www.hetzner.com/cloud?country=us) with network support.

## Usage

# Terraform

- Install the [terraform cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Create a Hetzner project

1. Open the [console](https://console.hetzner.cloud) and create a [project](https://docs.hetzner.com/cloud/general/faq). The name `k8s-stand` will be used next.
2. Create an [api token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token) with *Read & Write* permissions for the project `k8s-stand`.

### Generate SSH keys for servers

Generate new SSH keys in your terminal called `id_hetzner_entrance` and `id_hetzner_nodes`. The argument provided with the -f flag creates the key in the current directory and creates four files: `id_hetzner_entrance`, `id_hetzner_entrance.pub`, `id_hetzner_nodes`, and `id_hetzner_nodes.pub`. Replace the placeholder email address with your own email address.

- Generate a SSH key for the entrance server

```sh
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_hetzner_entrance
```

- Generate ssh-key for internal connections

```sh
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_hetzner_nodes
```




# How to use

## Apply terraform configuration

```sh
git clone https://github.com/wondertalik/terraform-k8s-hcloud
terraform init
terraform plan -out="k8s-stand.plan"
terraform apply "k8s-stand.plan"
```

## Reboot servers

For some reason, `cilium connectivity test` doesn't pass without reboot servers. To do it

```sh
terraform apply -auto-approve -var reboot_servers=true && terraform apply -auto-approve -var reboot_servers=false
```

## Variables

| Name                                       | Default                  | Description                                                                                                                                              | Required |
| :----------------------------------------- | :----------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| `cluster_name`                             | `kubernetes`             | Cluster name                                                                                                                                             |    No    |
| `hcloud_token`                             | ``                       | API Token that will be generated through your hetzner cloud project https://console.hetzner.cloud/projects                                               |   Yes    |
| `k8s_hcloud_token`                         | ``                       | API Token that will be generated through your hetzner cloud project https://console.hetzner.cloud/projects, used by k8s                                  |   Yes    |
| `user_name`                                | ``                       | User that wil be created in all nodes                                                                                                                    |   Yes    |
| `user_passwd`                              | ``                       | Password hash `` for new user created by [`mkpasswd --method=SHA-512 --rounds=4096`](https://cloudinit.readthedocs.io/en/latest/reference/examples.html) |   Yes    |
| `master_group`                             | `{}`                     | Amount of masters that will be created                                                                                                                   |    No    |
| `master_image`                             | `ubuntu-22.04`           | Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04)                                             |    No    |
| `worker_group_1`                           | `{}`                     | Amount of workers that will be created                                                                                                                   |    No    |
| `worker_image`                             | `ubuntu-22.04`           | Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04)                                             |    No    |
| `ingress_group`                            | `{}`                     | Amount of ingress-nginx that will be created                                                                                                             |    No    |
| `ingress_image`                            | `ubuntu-22.04`           | Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04)                                             |    No    |
| `entrance_image`                           | `ubuntu-22.04`           | Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-22.04, ubuntu-20.04)                                             |    No    |
| `entrance_type`                            | `cx11`                   | Machine type for more types have a look at https://www.hetzner.de/cloud                                                                                  |    No    |
| `ssh_private_key_entrance_hcloud`          | `id_hetzner_entrance`    | Name of the ssh key in hcloud for entrance server                                                                                                        |    No    |
| `ssh_private_key_entrance`                 | ``                       | Private Key to authorized the access for the entrance server                                                                                             |   Yes    |
| `ssh_public_key_entrance`                  | ``                       | Public Key to authorized the access for the entrance server                                                                                              |   Yes    |
| `ssh_private_key_nodes_hcloud`             | ``                       | Name of the ssh key in hcloud for the machines                                                                                                           |    No    |
| `ssh_private_key_nodes`                    | ``                       | Private Key to access the machines                                                                                                                       |   Yes    |
| `ssh_public_key_nodes`                     | ``                       | Public Key to authorized the access for the machines                                                                                                     |   Yes    |
| `private_network_ip_range`                 | `10.0.0.0/16`            | IP range of private network                                                                                                                              |    No    |
| `private_network_subnet_ip_range`          | `10.0.1.0/24`            | IP range of private sub network                                                                                                                          |    No    |
| `load_balancer_master_private_ip`          | `10.0.1.2`               | IP of the master load balancer                                                                                                                           |    No    |
| `master_load_balancer_type`                | `lb11`                   | Type of the loadbalancer, for more type have a look at https://docs.hetzner.com/cloud/load-balancers/overview                                            |    No    |
| `custom_ssh_port`                          | `21496`                  | Custom ssh port for open ssh server                                                                                                                      |    No    |
| `network_zone`                             | `eu-central`             | Predefined network zone                                                                                                                                  |    No    |
| `pod_network_cidr`                         | `10.0.16.0/20`           | The pod IPs that was created at installation time                                                                                                        |    No    |
| `location`                                 | `nbg1`                   | Predefined location, for more locations have a look at https://docs.hetzner.com/cloud/general/locations                                                  |    No    |
| `kubernetes_version`                       | `1.29.5`                 | Kubernetes version that will be installed                                                                                                                |    No    |
| `cilium_enabled`                           | `true`                   | Installs Cilium Network Provider after the master comes up                                                                                               |    No    |
| `cilium_custom_values_path`                | ``                       | Path to custom chart's values                                                                                                                            |    No    |
| `relay_ui_enabled`                         | `true`                   | Installs Ingress-Nginx after the ingress nodes comes up                                                                                                  |    No    |
| `hccm_enabled`                             | `true`                   | Installs Hetzner Cloud Provider after the master comes up                                                                                                |    No    |
| `hccm_custom_values_path`                  | ``                       | Path to custom chart's values                                                                                                                            |    No    |
| `ingress_enabled`                          | `true`                   | Installs Ingress-Nginx after the ingress nodes comes up                                                                                                  |    No    |
| `ingress_custom_values_path`               | ``                       | Path to custom chart's values                                                                                                                            |    No    |
| `ingress_load_balancer_name`               | `load-balancer-ingreses` | Ingess load balancer name                                                                                                                                |    No    |
| `ingress_load_balancer_type`               | `lb11`                   | Ingress load balancer type                                                                                                                               |    No    |
| `metric_server_enabled`                    | `false`                  | Installs Metrics Server after the master comes up                                                                                                        |    No    |
| `metric_server_custom_values_path`         | ``                       | Path to custom chart's values                                                                                                                            |    No    |
| `oauth2_proxy_enabled`                     | `false`                  | Copy oauth2 proxy chart to entrance server                                                                                                               |    No    |
| `oauth2_proxy_install`                     | `false`                  | Installs oauth2 proxy chart to entrance server                                                                                                           |    No    |
| `oauth2_proxy_custom_values_path`          | ``                       | Path to custom chart's values                                                                                                                            |    No    |
| `loki_enabled`                             | `false`                  | Copy Loki chart to entrance server                                                                                                                       |    No    |
| `loki_install`                             | `false`                  | Installs Loki chart to entrance server                                                                                                                   |    No    |
| `loki_custom_values_path`                  | ``                       | Path to custom chart's values                                                                                                                            |    No    |
| `promtail_enabled`                         | `false`                  | Copy Promtail chart to entrance server                                                                                                                   |    No    |
| `promtail_install`                         | `false`                  | Installs Promtail chart to entrance server                                                                                                               |    No    |
| `promtail_custom_values_path`              | ``                       | Path to custom chart's values                                                                                                                            |    No    |
| `kube_prometheus_stack_enabled`            | `false`                  | Copy Kube Prometheus Stack chart to entrance server                                                                                                      |    No    |
| `kube_prometheus_stack_install`            | `false`                  | Installs Kube Prometheus Stack chart to entrance server                                                                                                  |    No    |
| `kube_prometheus_stack_custom_values_path` | ``                       | Path to custom chart's values                                                                                                                            |    No    |
| `cert_manager_enabled`                     | `true`                   | Installs Cert Manager after the master comes up                                                                                                          |    No    |
| `cert_manager_custom_values_path`          | ``                       | Path to custom chart's values                                                                                                                            |    No    |
| `cert_manager_acme_email`                  | ``                       | Email address used for ACME registration                                                                                                                 |    No    |
| `rabbitmq_enabled`                         | `false`                  | Copy RabbitMQ chart to entrance server                                                                                                                   |    No    |
| `rabbitmq_install`                         | `false`                  | Installs RabbitMQ chart to entrance server                                                                                                               |    No    |
| `rabbitmq_custom_values_path`              | ``                       | Path to custom chart's values                                                                                                                            |    No    |
| `reboot_servers`                           | `false`                  | Indicate to reboot all servers                                                                                                                           |    No    |

All variables cloud be passed through `environment variables` or a `tfvars` file.

An example for a `tfvars` file would be the following `terraform.tfvars`

```toml
# terraform.tfvars
hcloud_token                             = "<yourgeneratedtoken>"
k8s_hcloud_token                         = "<yourgeneratedtoken>"
master_group                             = { "master-1" = { type = "cx21" }, }
asset_group                              = { "asset-1" = { type = "cx21" } }
postgresql_group                         = { "postgresql-1" = { type = "cx31", post_setup_script_path = "values/postgresql/setup-my-db.sh", image = "ubuntu-22.04", locale = "es_ES.UTF-8" } }
worker_group_1                           = { "worker-1" = { type = "cax11" }, "worker-3" = { type = "ccx13" }, "worker-2" = { type = "cx31" } }
ingress_group                            = { "ingress-1" = { type = "cx21" } }
ssh_private_key_entrance                 = "~/.ssh/id_hetzner_entrance"
ssh_public_key_entrance                  = "~/.ssh/id_hetzner_entrance.pub"
ssh_private_key_nodes                    = "~/.ssh/id_hetzner_nodes"
ssh_public_key_nodes                     = "~/.ssh/id_hetzner_nodes.pub"
user_name                                = "admin"
user_passwd                              = "<yourgeneratedtoken>"
```

**Tested with**

- Terraform [v1.8.3](https://github.com/hashicorp/terraform/tree/v1.4.4)
- provider.hcloud [v1.45.0](https://github.com/terraform-providers/terraform-provider-hcloud)
- hashicorp/null [v3.2.2](https://github.com/terraform-providers/terraform-provider-hcloud)
- hashicorp/cloudinit [v2.3.3](https://registry.terraform.io/providers/hashicorp/cloudinit)

** Charts **
- hccm [v1.19.0](https://github.com/hetznercloud/hcloud-cloud-controller-manager/blob/main/chart/README.md)
- cilium [1.15.5](https://artifacthub.io/packages/helm/cilium/cilium)
- oauth2-proxy [7.5.4](https://artifacthub.io/packages/helm/oauth2-proxy/oauth2-proxy)
- metrics-server [3.12.1](https://artifacthub.io/packages/helm/metrics-server/metrics-server)
- loki [5.5.2](https://artifacthub.io/packages/helm/grafana/loki)
- promtail [6.11.2](https://artifacthub.io/packages/helm/grafana/promtail)
- kube-prometheus-stack [58.6.0](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)
- cert-manager [1.14.5](https://artifacthub.io/packages/helm/cert-manager/cert-manager)
- ingress-nginx [4.10.1](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx)
- rabbitmq-cluster-operator [4.2.10](https://artifacthub.io/packages/helm/bitnami/rabbitmq-cluster-operator)

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/wondertalik/terraform-k8s-hcloud/issues) to report any bugs or file feature requests.

P.S. This repository is inspired by [aslubsky/terraform-k8s-hcloud](https://github.com/aslubsky/terraform-k8s-hcloud)