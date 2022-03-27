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

# Install dependencies in order to run a jenkins server container 
# I decided to run jenkins on a container after reading this article: https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code
# sudo apt-get update -y
# sudo apt install openjdk-11-jdk -y
# sudo apt install docker.io -y
# sudo apt install python3-docker -y
# sudo systemctl start docker
# sudo systemctl enable docker
# sudo usermod -aG docker ubuntu
# mkdir -p /home/ubuntu/jenkins_home
# sudo chown -R 1000:1000 /home/ubuntu/jenkins_home
# sudo docker run -d --name jenkins_server --restart=always  -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_home:/var/jenkins_home \
# -v /var/run/docker.sock:/var/run/docker.sock --env JAVA_OPTS='-Djenkins.install.runSetupWizard=false' jenkins/jenkins
# consider removing the java_opts parameter