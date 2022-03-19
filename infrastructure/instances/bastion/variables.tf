# EC2 Instance type
variable "instance_type" {
  description = "The type of EC2 instance"
  default     = "t2.micro"
  type        = string
}

# The number of instances to create
variable "number_of_instances" {
  description = "The number of instances to create"
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

variable "instance_name" {
  description = "The name that will be given to the instance - for the aws tag Name"
  type        = string
  default     = "bastion-server"  
}

# The IAM profile that will be assigned to the instance
variable "ec2_instance_iam_profile" {
  description = "The IAM profile that will be assigned to the instance"
  type        = string
}