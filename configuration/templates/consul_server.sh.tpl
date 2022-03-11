#!/usr/bin/env bash
# This script installs consul server
# consul is set up as a systemd service, which requiers a daemon-reload.

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Get the private IPs of the instances
echo "Grabbing IPs"
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

# Install dependencies in order to install consul
echo "Installing dependencies"
apt-get -qq update &>/dev/null
apt-get -yqq install unzip dnsmasq &>/dev/null


echo "Configuring dnsmasq"
cat << EODMCF >/etc/dnsmasq.d/10-consul
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EODMCF

systemctl restart dnsmasq

cat << EOF >/etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF

systemctl restart systemd-resolved.service

echo "Fetching Consul"
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip

echo "Installing Consul"
unzip consul.zip >/dev/null
chmod +x consul
mv consul /usr/local/bin/consul

# Setup Consul
mkdir -p /opt/consul
mkdir -p /etc/consul.d
mkdir -p /run/consul

tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "data_dir": "/opt/consul",
  "datacenter": "${datacenter_name}",
  "node_name": "${node_name}",
  "encrypt": "fwz6Zxm/TJfpyzOYHC9A1D+YJpCabdhU3FHU+ASWylI=",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=consul_server tag_value=true"],
  "enable_script_checks": true,
  "server": true,
  "bootstrap_expect": 3,
  "ui": true,
  "client_addr": "0.0.0.0",
  "telemetry": {
    "prometheus_retention_time": "10m"
  }
}
EOF

# Create user & grant ownership of folders
useradd consul
chown -R consul:consul /opt/consul /etc/consul.d /run/consul

# Configure consul service
tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description="Consul service discovery agent"
Requires=network-online.target
After=network.target
[Service]
User=consul
Group=consul
PIDFile=/run/consul/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent -pid-file=/run/consul/consul.pid -config-dir=/etc/consul.d
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5
[Install]
WantedBy=multi-user.target
EOF

sleep 30

systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service

exit 0