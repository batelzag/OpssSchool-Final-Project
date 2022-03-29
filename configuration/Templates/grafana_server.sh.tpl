#!/usr/bin/env bash
# This script installs and configures grafana server
# grafana is set up as a systemd service, which requiers a daemon-reload.

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Install grafana
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_${grafana_version}_amd64.deb
sudo dpkg -i grafana-enterprise_${grafana_version}_amd64.deb

# Setting the relevant data sources for grafana (prometheus servers on ec2 and eks)
sudo tee /etc/grafana/provisioning/datasources/datasources.yml > /dev/null <<EOF
apiVersion: 1
datasources:
  - name: prometheus
    type: prometheus
    access: proxy
    url: http://prometheus-server.service.final-project.consul:9090
    isDefault: true
  - name: CloudWatch
    type: cloudwatch
    access: proxy
    orgId: 1
    jsonData:
      defaultRegion: "us-east-1"
    version: 1
    editable: false
EOF

sudo cp /home/ubuntu/Grafana/dashboards/* /etc/grafana/provisioning/dashboards
sudo rm -r /home/ubuntu/Grafana

sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Configure grafana server service with proper health checks
sudo tee /etc/consul.d/grafana_server.json > /dev/null <<EOF
{
  "service": {
    "id": "grafana-server",
    "name": "grafana-server",
    "port": 3000,
    "tags": ["grafana", "grafana-server", "monitoring"],
    "checks": [
      {
        "name": "HTTP API on port 3000",
        "http": "http://localhost:3000/",
        "interval": "30s",
        "timeout": "5s"
      },
      {
        "name": "tcp on port 3000",
        "tcp": "localhost:3000",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "name": "grafana deamon",
        "args": ["systemctl", "status", "grafana-server"],
        "interval": "60s"
      }
    ]
  }
}

EOF

# Register the grafana server service to consul by reloading the consul service
consul reload

exit 0