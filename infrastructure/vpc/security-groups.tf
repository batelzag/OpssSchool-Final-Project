# Create suitable security groups for all of the instances in the project

# Create a dedicated SG for jenkins Server
resource "aws_security_group" "jenkins_server_sg" {
  name          = "jenkins_server"
  description   = "Allow Jenkins server inbound traffic"
  vpc_id        = aws_vpc.project-vpc.id

  ingress {
    description = "Allow UI access from the world"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #consider changing to my ip only.
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a dedicated SG for consul Servers
resource "aws_security_group" "consul_servers_sg" {
  name          = "consul_servers"
  description   = "Allow Consul server inbound traffic"
  vpc_id        = aws_vpc.project-vpc.id

  ingress {
    description = "Allow UI access from the world"
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #consider changing to my ip only.
  }

  ingress {
    description     = "For handeling requests from consul agents"
    from_port       = 8300
    to_port         = 8300
    protocol        = "tcp"
    security_groups = [aws_security_group.consul_agents_sg.id]
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a dedicated SG for consul nodes\agents 
resource "aws_security_group" "consul_agents_sg" {
  name          = "consul_agents"
  description   = "allows ssh & consul cluster inbound traffic"
  vpc_id        = aws_vpc.project-vpc.id

  ingress {
    description     = "Allow ssh inside sg and from bastion server"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    self            = true
    security_groups = [aws_security_group.bastion_server_sg.id]
  }

  ingress {
    description = "Allow gossip between consul servers and agents"
    from_port   = 8301
    to_port     = 8302
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow DNS requests inside sg"
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow node exporter scarping inside sg"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow all outside security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a dedicated SG for bastion Server
resource "aws_security_group" "bastion_server_sg" {
  name          = "bastion_server"
  description   = "Allow Bastion inbound traffic"
  vpc_id        = aws_vpc.project-vpc.id

  ingress {
    description = "Allow ssh from my ip address only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  
  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a dedicated SG for prometheus Server
resource "aws_security_group" "prometheus_server_sg" {
  name          = "prometheus-server"
  description   = "Allow prometheus server inbound traffic"
  vpc_id        = aws_vpc.project-vpc.id

  ingress {
    description = "Allow UI access from the world"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #consider changing to my ip only.
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a dedicated SG for grafana Server
resource "aws_security_group" "grafana_server_sg" {
  name          = "grafana-server"
  description   = "Allow grafana server inbound traffic"
  vpc_id        = aws_vpc.project-vpc.id

  ingress {
    description = "Allow UI access from the world"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #consider changing to my ip only.
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}