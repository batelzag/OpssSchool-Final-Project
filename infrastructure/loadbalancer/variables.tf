# The vpc id in which to deploy instances
variable  "vpc_id" {
  description = "The vpc id in which to deploy the instance"
  type        = string
}

# The subnets ids that will be assigned to the instance
variable "subnets_id" {
  description = "The subnets ids that will be assigned to the instance"
  type        = list(string)
}

# The security groups that will be assigned to the instance
variable "ec2_instance_security_groups" {
  description = "The security groups that will be assigned to the instance"
  type        = list(string)
}

variable "consul_servers_target_group" {
  description = "The Target security group that will be assigned to the ALB"
  type        = list(string)
}  

variable "jenkins_server_target_group" {
  description = "The Target security group that will be assigned to the ALB"
  type        = list(string)
}

variable "prometheus_server_target_group" {
  description = "The Target security group that will be assigned to the ALB"
  type        = list(string)
}

variable "grafana_server_target_group" {
  description = "The Target security group that will be assigned to the ALB"
  type        = list(string)
}

variable "elk_server_target_group" {
  description = "The Target security group that will be assigned to the ALB"
  type        = list(string)
}  