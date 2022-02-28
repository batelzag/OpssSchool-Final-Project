# Retrieves the free Availability Zone on AWS
data "aws_availability_zones" "available-AZ" {}

# Retrieves my IP address in order to secure the SG of the bastion
data "http" "myip" {
    url = "http://ipv4.icanhazip.com"
}