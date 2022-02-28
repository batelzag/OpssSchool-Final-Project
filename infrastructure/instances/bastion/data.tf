# Retrieves Info about the latest ubuntu version
data "aws_ami" "ubuntu-18" {
    most_recent = true
    owners      = ["099720109477"]

    filter {
        name    = "name"
        values  = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
        name    = "root-device-type"
        values  = ["ebs"]
    }
    
    filter {
        name    = "virtualization-type"
        values  = ["hvm"]
    }
}