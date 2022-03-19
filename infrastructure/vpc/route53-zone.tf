# Creat Route53 private hosted zone
resource "aws_route53_zone" "private" {
  name        = var.route53_domain_name

  vpc {
    vpc_id = aws_vpc.project-vpc.id
  }
  
  tags = {
    Name = "${var.route53_domain_name}-private-zone"
  }
}

# Change the default DHCP options settings to search addresses on the route53 private zone domain name
resource "aws_vpc_dhcp_options" "dhcp_domain_name" {
  domain_name = var.route53_domain_name
  domain_name_servers  = ["AmazonProvidedDNS"]

  tags = {
    Name = "${var.route53_domain_name}-private-zone"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.project-vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_domain_name.id
}