#!/bin/bash

# This script downloads and installs node_exporter of the requested version on a host.
# node_exporter is set up as a systemd service, which requiers a daemon-reload.

wget \
  https://github.com/prometheus/node_exporter/releases/download/v${node_exporter_version}/node_exporter-${node_exporter_version}.linux-amd64.tar.gz \
  -O /tmp/node_exporter-${node_exporter_version}.linux-amd64.tar.gz

sudo tar zxvf /tmp/node_exporter-${node_exporter_version}.linux-amd64.tar.gz

sudo cp ./node_exporter-${node_exporter_version}.linux-amd64/node_exporter /usr/local/bin
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo mkdir -p /var/lib/node_exporter/textfile_collector
sudo chown node_exporter:node_exporter /var/lib/node_exporter
sudo chown node_exporter:node_exporter /var/lib/node_exporter/textfile_collector

sudo tee /etc/systemd/system/node_exporter.service &>/dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector \
 --no-collector.infiniband
[Install]
WantedBy=multi-user.target
EOF

sudo rm -rf /tmp/node_exporter-${node_exporter_version}.linux-amd64.tar.gz \
  ./node_exporter-${node_exporter_version}.linux-amd64

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status --no-pager node_exporter

# Configure node exporter service with proper health checks
sudo tee /etc/consul.d/node_exporter.json > /dev/null <<EOF
{
  "service": {
    "id": "node-exporter",
    "name": "node-exporter",
    "port": 9100,
    "tags": ["node-exporter", "monitoring"],
    "checks": [
      {
        "name": "node-exporter deamon",
        "args": ["systemctl", "status", "node_exporter"],
        "interval": "60s"
      },
      {
        "name": "tcp on port 9100",
        "tcp": "localhost:9100",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}

EOF

# Register the node exporter service to consul by reloading the consul service
consul reload

exit 0