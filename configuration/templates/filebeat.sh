#!/usr/bin/env bash
# This script installs and configures filebeat - in order to send logs to elasticsearch server

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Install filebeat
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-${filebeat_version}-amd64.deb
dpkg -i filebeat-*.deb

sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.BCK

sudo tee /etc/filebeat/filebeat.yml > /dev/null <<EOF
# filebeat.inputs:
#   - type: log
#     enabled: false
#     paths:
#       - /var/log/*.log
#       - /var/log/auth.log
#       - /var/log/syslog

  - type: container
    enabled: false
    paths:
      - "/var/lib/docker/containers/*/*.log"
filebeat.autodiscover:
  providers:
    - type: docker
      templates:
        - condition:
            regexp:
              docker.container.image: ".*" # all other containers
          config:
            - type: container
              paths:
                - /var/lib/docker/containers/${data.docker.container.id}/*.log
              processors:
                - decode_json_fields:
                    fields: ["message"]
                    max_depth: 1
                    target: ""
                    overwrite_keys: true
                    when:
                      regexp:
                        message: '^{'
filebeat.modules:
  - module: system
    syslog:
      enabled: true
    auth:
      enabled: true

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

setup.dashboards.enabled: true
setup.template.name: "filebeat"
setup.template.pattern: "filebeat-*"
setup.template.settings:
  index.number_of_shards: 1

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~
#  - add_docker_metadata:
#      host: "unix://var/run/docker.sock"

output.elasticsearch:
  hosts: [ "${elk_host}:9200" ]
  index: "filebeat-%{[agent.version]}-%{+yyyy.MM.dd}"

setup.kibana.host: "${elk_host}:5601"
setup.kibana.protocol: "http"

EOF

sudo systemctl enable filebeat
sudo systemctl start filebeat

# Configure filebeat service with proper health checks
sudo tee /etc/consul.d/filebeat.json > /dev/null <<EOF
{
  "service": {
    "id": "filebeat-service",
    "name": "filebeat-service",
    "port": 9200,
    "tags": ["filebeat", "logging"],
    "checks": [
      {
        "name": "filebeat service",
        "args": ["systemctl", "status", "filebeat"],
        "interval": "60s"
      }
    ]
  }
}

EOF

# Register the filebeat service to consul by reloading the consul service
consul reload

exit 0