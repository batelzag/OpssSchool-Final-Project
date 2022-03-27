#!/usr/bin/env bash
# This script configures bastion

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Configure bastion service with proper health checks
sudo tee /etc/consul.d/bastion_server.json > /dev/null <<EOF
{
  "service": {
    "id": "bastion-server",
    "name": "bastion-server",
    "tags": ["bastion-server", "bastion"]
  }
}

EOF

# Register the bastion server service to consul by reloading the consul service
consul reload

sleep 90

sudo systemctl restart filebeat

exit 0