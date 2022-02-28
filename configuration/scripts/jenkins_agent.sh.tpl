#!/usr/bin/env bash
# This script installs jenkins for jenkins server and registers the service of the jenkins server

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Install the requierd pkg for jenkins agent
sudo apt-get update -y
sudo apt install openjdk-11-jdk -y
sudo apt install docker.io -y
sudo service docker start
sudo usermod -aG docker ubuntu
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker
sudo chmod 666 /var/run/docker.sock

# Configure jenkins agent service
sudo tee /etc/consul.d/jenkins_agent.json > /dev/null <<EOF
{
  "service": {
    "id": "jenkins-agent",
    "name": "jenkins-agent",
    "tags": ["jenkins", "jenkins agent", "consul agent"]
  }
}

EOF

# Register the jenkins agent service to consul by reloading the consul service
consul reload

exit 0
# #install kubectl (In case the k8s junkins plugin doesn't work)
# curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
# curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.7.0/bin/linux/amd64/kubectl
# chmod +x ./kubectl
# sudo mv ./kubectl /usr/local/bin/kubectl
# sudo snap install kubectl --classic
# #install aws cli
# sudo apt install awscli