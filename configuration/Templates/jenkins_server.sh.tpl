#!/usr/bin/env bash
# This script installs and configures jenkins server

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# If I decide to change and run jenkins on the machine and not on docker
sudo apt-get update -y
sudo apt install openjdk-11-jdk -y

wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update -y 
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo usermod -aG jenkins ubuntu
sudo systemctl daemon-reload

# Configure jenkins server service with proper health checks
sudo tee /etc/consul.d/jenkins_server.json > /dev/null <<EOF
{
  "service": {
    "id": "jenkins-server",
    "name": "jenkins-server",
    "port": 8080,
    "tags": ["jenkins", "jenkins-server", "docker"],
    "checks": [
      {
        "name": "HTTP API on port 8080",
        "http": "http://localhost:8080/login",
        "interval": "30s",
        "timeout": "5s"
      },
      {
        "name": "tcp on port 8080",
        "tcp": "localhost:8080",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "name": "jenkins deamon",
        "args": ["systemctl", "status", "jenkins"],
        "interval": "60s"
      }
    ]
  }
}

EOF

# Register the jenkins server service to consul by reloading the consul service
consul reload

exit 0