resource "aws_route53_record" "instance_alias_record" {
  zone_id = var.vpc_route53_zone
  name    = "${var.instance_name}"
  type    = "A"

  alias {
    name = aws_db_instance.db-instance.address
    zone_id = aws_db_instance.db-instance.hosted_zone_id
    evaluate_target_health = true
  }
}