resource "aws_route53_record" "alb_alias_record" {
  zone_id = var.vpc_route53_zone
  name    = "${var.alb_name}"
  type    = "A"

  alias {
    name = aws_lb.private-resources-alb.dns_name
    zone_id = aws_lb.private-resources-alb.zone_id
    evaluate_target_health = true
  }
}