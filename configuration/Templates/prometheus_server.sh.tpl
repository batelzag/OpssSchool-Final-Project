#!/usr/bin/env bash
# This script installs and configures prometheus server
# prometheus is set up as a systemd service, which requiers a daemon-reload.


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

  - job_name: 'node_exporters_ec2'
    consul_sd_configs:
      - server: 'localhost:8500'
    relabel_configs:
      - source_labels: ['__address__']
        target_label: '__address__'
        regex: '(.*):(.*)'
        replacement: '\$1:9100'
      - source_labels: ['__meta_consul_node']
        target_label: 'instance'
      - source_labels: ['__meta_consul_node']
        target_label: 'instance'
        regex: '(.*)db-server(.*)'
        action: drop
      - source_labels: ['__meta_consul_node']
        target_label: 'instance'
        regex: '(.*)k8s(.*)'
        action: drop
  
  - job_name: 'node_exporters_eks'
    metrics_path: '/metrics'
    consul_sd_configs:
      - server: 'localhost:8500'
        services: 
          - prometheus-node-exporter-monitoring
    relabel_configs:
      - source_labels: ['__meta_consul_service_id']
        target_label: 'pod'

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
      - source_labels: ['__meta_consul_node']
        target_label: 'instance'

  - job_name: 'jenkins'
    metrics_path: '/prometheus/'
    consul_sd_configs:
      - server: 'localhost:8500'
        services:
          - jenkins-server
    relabel_configs:
      - source_labels: ['__meta_consul_node']
        target_label: 'instance'

  - job_name: 'kandula-app'
    metrics_path: '/metrics'
    consul_sd_configs:
      - server: 'localhost:8500'
        services: 
          - kandula-project-lb-default
    relabel_configs:
      - source_labels: ['__address__']
        target_label: '__address__'
        regex: '(.*):(.*)'
        replacement: '\$1:9100'
      - source_labels: ['__meta_consul_service_id']
        target_label: 'pod'

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
    "tags": ["prometheus", "prometheus-server", "monitoring"],
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
      },
      {
        "name": "prometheus deamon",
        "args": ["systemctl", "status", "prometheus"],
        "interval": "60s"
      }
    ]
  }
}

EOF

# Register the prometheus server service to consul by reloading the consul service
consul reload

exit 0