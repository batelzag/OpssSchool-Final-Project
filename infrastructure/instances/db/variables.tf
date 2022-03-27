# EC2 Instance type
variable "instance_type" {
  description = "The type of EC2 instance"
  default     = "db.t2.micro"
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
variable "db_instance_security_groups" {
  description = "The security groups that will be assigned to the instance"
  type        = list(string)
}

variable "instance_name" {
  description = "The name that will be given to the instance - for the aws tag Name"
  type        = string
  default     = "db-server"  
}

# # The IAM profile that will be assigned to the instance
# variable "ec2_instance_iam_profile" {
#   description = "The IAM profile that will be assigned to the instance"
#   type        = string
# }

variable "db_name" {
  description = "The database name"
  type        = string
  default     = "kanduladb"  
}

variable "db_port_number" {
  description = "The database port number"
  type        = string
  default     = "5432"  
}

variable "db_storage" {
  description = "Database allocated storage"
  type        = number
  default     = 20 
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}