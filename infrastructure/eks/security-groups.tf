resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

# Create a dedicated SG for prometheus Server on k8s
resource "aws_security_group" "prometheus_k8s_server_sg" {
  name          = "prometheus_k8s_server_sg"
  description   = "Allow k8s prometheus server inbound traffic"
  vpc_id        = var.vpc_id

  ingress {
    description = "Allow UI access from the world"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]  
  }
}
# resource "aws_security_group" "consul_k8s_sg" {
#   name        = "consul_k8s_sg"
#   description = "allows consul cluster traffic"
#   vpc_id      = var.vpc_id

#   ingress {
#     description     = "Allow gossip between consul servers and agents"
#     from_port       = 8301
#     to_port         = 8302
#     protocol        = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] 
#     # security_groups = [var.consul_agents_sg] ##
#   }

#     ingress {
#     description     = "Allow DNS requests inside sg"
#     from_port       = 8600
#     to_port         = 8600
#     protocol        = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] 
#     # security_groups = [var.consul_agents_sg] ##
#   }
# }