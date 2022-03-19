# EC2 Instance type
variable "instance_type" {
  description = "The type of EC2 instance"
  default     = "t2.micro"
  type        = string
}

# The number of instances to create
variable "number_of_instances" {
  description = "The number of jenkins agents to create"
}

# The key name for EC2 instance
variable "key_name" {
  description = "The key name of the Key Pair to use for the instance"
  type        = string
}

# The vpc id in which to deploy instances
variable  "vpc_id" {
  description = "The vpc id in which to deploy the instance"
  type        = string
}

# The Route53 private zone id
variable "vpc_route53_zone" {
  description = "the vpc's privat route53 hosted zone"
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

# The IAM profile that will be assigned to the instance
variable "ec2_instance_iam_profile" {
  description = "The IAM profile that will be assigned to the instance"
  type        = string
}

variable "instance_name" {
  description = "The name that will be given to the instance - for the aws tag Name and for the consul node name"
  type        = string
  default     = "grafana-server"  
}

# The Bastion server IP address for provisioning files
variable "bastion_public_ip" {
  description = "The public IP of the bastion server"
  type        = string
}