# Output the vpc id
output "vpc_id" {
    value       = aws_vpc.project-vpc.id
    description = "the id of the vpc"
}

# Output the vpc cidr
output "vpc_cidr" {
    value       = aws_vpc.project-vpc.cidr_block
    description = "the cidr block of the VPC"
}

# Output the Route53 private zone
output "vpc_route53_zone" {
    value       = aws_route53_zone.private.zone_id
    description = "the zone id of the route53 private hosted zone"
}

# Output the public subnets ids
output "public_subnets" {
    value       = "${aws_subnet.public.*.id}"
    description = "the ids of the public subnets"
}

# Output the private subnets ids
output "private_subnets" {
    value       = "${aws_subnet.private.*.id}"
    description = "the ids of the privete subnets"
}

# Output the jenkins server security group id
output "jenkins_server_sg" {
    value       = aws_security_group.jenkins_server_sg.id
    description = "the id of the security group assigned to the jenkins server"
}

# Output the jenkins eks access arn
output "jenkins_eks_role" {
    value       = aws_iam_role.jenkins-access-eks-role.arn
    description = "the arn of the jenkins eks access role"
}

# Output the consul servers security group id
output "consul_servers_sg" {
    value       = aws_security_group.consul_servers_sg.id
    description = "the id of the security group assigned to the consul servers"
}

# Output the consul agents security group id
output "consul_agents_sg" {
    value       = aws_security_group.consul_agents_sg.id
    description = "the id of the security group assigned to the consul agents"
}

# Output the prometheus server security group id
output "prometheus_server_sg" {
    value       = aws_security_group.prometheus_server_sg.id
    description = "the id of the security group assigned to the prometheus server"
}

# Output the grafana server security group id
output "grafana_server_sg" {
    value       = aws_security_group.grafana_server_sg.id
    description = "the id of the security group assigned to the grafana server"
}

# Output the elk server security group id
output "elk_server_sg" {
    value       = aws_security_group.elk_server_sg.id
    description = "the id of the security group assigned to the elk server"
}

# Output the bastion server security group id
output "bastion_server_sg" {
    value       = aws_security_group.bastion_server_sg.id
    description = "the id of the security group assigned to the bastion server"
}

# Output the db server security group id
output "db_server_sg" {
    value       = aws_security_group.db_server_sg.id
    description = "the id of the security group assigned to the db server"
}

# Output the filebeat security group id
output "filebeat_sg" {
    value       = aws_security_group.filebeat_sg.id
    description = "the id of the security group assigned to filebeat"
}

# Output the node exporter security group id
output "node_exporter_sg" {
    value       = aws_security_group.node_exporter_sg.id
    description = "the id of the security group assigned to filebeat"
}

# Output the ssh security group id
output "ssh_sg" {
    value       = aws_security_group.ssh_sg.id
    description = "the id of the security group assigned to filebeat"
}

# Output the consul agents iam profile
output "consul-join-profile" {
    value       = aws_iam_instance_profile.consul-join-profile.name
    description = "the name of IAM profile to attach to the instance"
}

# Output the jenkins agents iam profile
output "jenkins-access-eks-profile" {
    value       = aws_iam_instance_profile.jenkins-access-eks-profile.name
    description = "the name of IAM profile to attach to the instance"
}

# Output the jenkins agents iam profile
output "grafana-cloudwatch-profile" {
    value       = aws_iam_instance_profile.grafana-cloudwatch-profile.name
    description = "the name of IAM profile to attach to the instance"
}

# Output the name of the pem key that was created
output "pem_key_name" {
    value = aws_key_pair.project_key.key_name
}