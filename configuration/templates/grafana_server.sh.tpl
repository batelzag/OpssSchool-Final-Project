#!/usr/bin/env bash
# This script installs and configures grafana server
# grafana is set up as a systemd service, which requiers a daemon-reload.

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Install grafana
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_${grafana_version}_amd64.deb
sudo dpkg -i grafana-enterprise_${grafana_version}_amd64.deb

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
    "tags": ["grafana", "consul agent", "monitoring"],
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
      }
    ]
  }
}

EOF

# Register the grafana server service to consul by reloading the consul service
consul reload

exit 0