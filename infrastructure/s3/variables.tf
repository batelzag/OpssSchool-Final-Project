# The name of s3 bucket to create - needs to be unique(!)
variable s3_bucket_name {
  type        = string
  default     = "terraformstate-environments/Development/" #${random_string.suffix.result}
  description = "the name of s3 bucket to create"
}

# The region in which to create the s3 bucket
variable s3_bucket_region {
  type        = string
  default     = "us-east-1"
  description = "the name of s3 bucket to create"
}