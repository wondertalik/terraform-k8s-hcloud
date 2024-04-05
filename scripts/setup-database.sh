#!/bin/bash
set -eux

#for sharedVcpu servers x86_64
NODE_PRIVATE_IP=$(ip -4 -o a show ens10 | awk '{print $4}' | cut -d/ -f1)
if [ -z "$NODE_PRIVATE_IP" ]; then
  #for sharedVcpu servers arm64 (ampere) and dedicated servers
  NODE_PRIVATE_IP=$(ip -4 -o a show enp7s0 | awk '{print $4}' | cut -d/ -f1)
fi

sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null

apt -y update && apt -y install postgresql-16

# until sudo -u postgres psql -c '\l'; do
#   echo >&2 "$(date +%Y%m%dt%H%M%S) Postgres is unavailable - sleeping"
#   sleep 1
# done
# echo >&2 "$(date +%Y%m%dt%H%M%S) Postgres is up - executing command"

# sleep 40

# need remove cluster by default to create with es locale
pg_dropcluster --stop 16 main
pg_createcluster --locale $CLUSTER_LOCALE 16 main
systemctl start postgresql

#change listen_addresses and add private k8s network
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost,$NODE_PRIVATE_IP'/" /etc/postgresql/16/main/postgresql.conf
echo "#connections from private k8s network" >> /etc/postgresql/16/main/pg_hba.conf
echo "host    all             all             $PRIVATE_NETWORK_SUBNET_IP_RANGE           scram-sha-256" >> /etc/postgresql/16/main/pg_hba.conf

systemctl restart postgresql