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

# Output the bastion server security group id
output "bastion_server_sg" {
    value       = aws_security_group.bastion_server_sg.id
    description = "the id of the security group assigned to the bastion server"
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

# Output the name of the pem key that was created
output "pem_key_name" {
    value = aws_key_pair.mid_project_key.key_name
}