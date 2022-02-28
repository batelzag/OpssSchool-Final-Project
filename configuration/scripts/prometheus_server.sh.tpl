#!/usr/bin/env bash
# This script installs and configures prometheus server

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Install Prometheus Collector
wget https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/prometheus-${prometheus_version}.linux-amd64.tar.gz -O /tmp/prometheus.tgz
mkdir -p ${prometheus_dir}
tar zxf /tmp/prometheus.tgz -C ${prometheus_dir}

# Create prometheus configuration
mkdir -p ${prometheus_conf_dir}
tee ${prometheus_conf_dir}/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporters'
    consul_sd_configs:
      - server: 'localhost:8500'
    relabel_configs:
      - source_labels: ['__address__']
        target_label: '__address__'
        regex: '(.*):(.*)'
        replacement: '\$1:9100'
      - source_labels: ['__meta_consul_node']
        target_label: 'instance'

  - job_name: 'consul'
    metrics_path: '/v1/agent/metrics'
    params:
      format: ['prometheus']
    consul_sd_configs:
      - server: 'localhost:8500'
        services: 
          - consul
    relabel_configs:
      - source_labels: ['__address__']
        target_label: '__address__'
        regex: '(.*):(.*)'
        replacement: '\$1:8500'

EOF

# Configure prometheus service
tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus Collector
Requires=network-online.target
After=network.target
[Service]
ExecStart=${prometheus_dir}/prometheus-${prometheus_version}.linux-amd64/prometheus --config.file=${prometheus_conf_dir}/prometheus.yml
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
TimeoutStopSec=5
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Configure prometheus server service with proper health checks
sudo tee /etc/consul.d/prometheus_server.json > /dev/null <<EOF
{
  "service": {
    "id": "prometheus-server",
    "name": "prometheus-server",
    "port": 9090,
    "tags": ["prometheus", "consul agent", "monitoring"],
    "checks": [
      {
        "name": "HTTP API on port 9090",
        "http": "http://localhost:9090/",
        "interval": "30s",
        "timeout": "5s"
      },
      {
        "name": "tcp on port 9090",
        "tcp": "localhost:9090",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}

EOF

# Register the prometheus server service to consul by reloading the consul service
consul reload

exit 0