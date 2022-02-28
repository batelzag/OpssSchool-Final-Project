# Defines the vpc cidr
variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

# Number of private subnets to create
variable "number_of_private_subnets" {
    default = 2
}

# Number of public subnets to create
variable "number_of_public_subnets" {
    default = 2
}

# The key name for EC2 instance
variable "key_name" {
    description = "The key name of the Key Pair to use for the instance"
    type        = string
}