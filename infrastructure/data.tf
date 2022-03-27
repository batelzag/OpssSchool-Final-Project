data "aws_s3_bucket" "project-s3-remotestate" {
  bucket = var.s3_bucket_name
}