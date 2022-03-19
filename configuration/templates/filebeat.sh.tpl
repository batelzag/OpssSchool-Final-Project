#!/usr/bin/env bash
# This script installs and configures filebeat - in order to send logs to elasticsearch server

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Suspend filebeat installtion for 30 sec in order until elk server fully up
sleep 30

# Install filebeat
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-oss-${filebeat_version}-amd64.deb
dpkg -i filebeat-*.deb

sudo mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.BCK

sudo cp /home/ubuntu/filebeat.yml /etc/filebeat
sudo rm /home/ubuntu/filebeat.yml

sudo systemctl daemon-reload
sudo systemctl enable filebeat
sudo systemctl start filebeat

# Configure filebeat service with proper health checks
sudo tee /etc/consul.d/filebeat.json > /dev/null <<EOF
{
  "service": {
    "id": "filebeat",
    "name": "filebeat",
    "port": 9200,
    "tags": ["filebeat", "logging"],
    "checks": [
      {
        "name": "filebeat deamon",
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