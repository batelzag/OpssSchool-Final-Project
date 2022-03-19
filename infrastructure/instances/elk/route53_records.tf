resource "aws_route53_record" "instance_a_record" {
  count   = var.number_of_instances
  zone_id = var.vpc_route53_zone
  name    = "${var.instance_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.ec2-instance.*.private_ip}"[count.index]]
}