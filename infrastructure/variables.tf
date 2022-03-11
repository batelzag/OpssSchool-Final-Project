# The AWS to deploy the insfrastructre
variable "aws_region" {
  description     = "AWS region"
  default         = "us-east-1"
}

# The S3 bucket name to create
variable s3_bucket_name {
  type            = string
  default         = "terraformstate-environments/Development/" #${random_string.suffix.result} - 
  description     = "the name of s3 bucket to store the remote state"
}

# The environment tag
variable "environment_tag" {
    type          = string
    description   = "which environment is it"
    default       = "development"
}

# The owner tag
variable "owner_tag" {
    type          = string
    description   = "who's the owner of the project"
    default       = "opsschool-batel"
}

# The project tag
variable "project_tag" {
    type          = string
    description   = "what is the project about"
    default       = "mid-project"
}