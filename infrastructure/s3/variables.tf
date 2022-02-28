# The name of s3 bucket to create - needs to be unique(!)
variable s3_bucket_name {
  type        = string
  default     = "terraformstate-environments/Development/" #${random_string.suffix.result}
  description = "the name of s3 bucket to create"
}