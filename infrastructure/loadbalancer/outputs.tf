# Output the ALB DNS Name 
output "alb_dns_name" {
    value       = aws_lb.private-resources-alb.dns_name
    description = "the dns name of the ALB"
}