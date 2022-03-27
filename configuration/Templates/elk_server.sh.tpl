#!/usr/bin/env bash
# This script installs and configures elasticsearch & kibana 

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Install ElasticSearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-${elasticsearch_version}-amd64.deb
dpkg -i elasticsearch-*.deb

echo 'network.host: 0.0.0.0' >> /etc/elasticsearch/elasticsearch.yml
echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml
echo 'indices.query.bool.max_clause_count: 2048' >> /etc/elasticsearch/elasticsearch.yml

systemctl enable elasticsearch
systemctl start elasticsearch

# Configure elasticsearch server service with proper health checks
sudo tee /etc/consul.d/elasticsearch_server.json > /dev/null <<EOF
{
  "service": {
    "id": "elasticsearch-server",
    "name": "elasticsearch-server",
    "port": 9200,
    "tags": ["elasticsearch", "elasticsearch-server", "logging", "elk"],
    "checks": [
      {
        "name": "tcp on port 9200",
        "tcp": "localhost:9200",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "name": "elasticsearch deamon",
        "args": ["systemctl", "status", "elasticsearch"],
        "interval": "60s"
      }
    ]
  }
}

EOF

# Install Kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-oss-${kibana_version}-amd64.deb
dpkg -i kibana-*.deb
echo 'server.host: "0.0.0.0"' > /etc/kibana/kibana.yml
# elastic.search.hosts: ["http://localhost:9200"]
systemctl enable kibana
systemctl start kibana

# Configure kibana server service with proper health checks
sudo tee /etc/consul.d/kibana_server.json > /dev/null <<EOF
{
  "service": {
    "id": "kibana-server",
    "name": "kibana-server",
    "port": 5601,
    "tags": ["kibana", "kibana-server", "logging", "elk"],
    "checks": [
      {
        "name": "HTTP API on port 5601",
        "http": "http://localhost:5601/",
        "interval": "30s",
        "timeout": "5s"
      },
      {
        "name": "tcp on port 5601",
        "tcp": "localhost:5601",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "name": "kibana service",
        "args": ["systemctl", "status", "kibana"],
        "interval": "60s"
      }
    ]
  }
}

EOF

# Register the kibana service and elasticsearch service to consul by reloading the consul service
consul reload

exit 0