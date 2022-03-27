# create an S3 bucket to store the state file in
resource "aws_s3_bucket" "project-s3-remotestate" {
    bucket = var.s3_bucket_name
    region = var.s3_bucket_region

    versioning {
      enabled = true
    }

    lifecycle {
      prevent_destroy = true
    }
    
    tags = {
      Name = "project-s3-remoteState"
    }      
}