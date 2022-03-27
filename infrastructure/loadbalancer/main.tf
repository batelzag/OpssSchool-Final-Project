# Create Application Load Balancer for access from the world to resources on the private subnets (consul & jenkins & prometheus & grafana & kibana)
resource "aws_lb" "private-resources-alb" {
  name                = "${var.alb_name}"
  internal            = false
  load_balancer_type  = "application"
  subnets             = var.subnets_id
  security_groups     = var.ec2_instance_security_groups

  # tags = {
  #   Name        = "private-resources-alb"
  #   description = "Load balancer for access to reasources on the private subnets"
  # }
}

# Creates a Target Group resource for use with ALB resources
resource "aws_lb_target_group" "consul-servers-tg" {
  name        = "consul-servers"
  port        = 8500
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
      port     = 8500
      protocol = "HTTP"
  }

  # tags = {
  #   Name = "consul-servers-tg"
  # }
}

# Creates a listner for ALB using http 
resource "aws_lb_listener" "consul-servers-listner" {
  load_balancer_arn = aws_lb.private-resources-alb.arn
  port              = 8500
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul-servers-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "consul_servers" {
  count            = 3
  target_group_arn = aws_lb_target_group.consul-servers-tg.arn
  target_id        = var.consul_servers_target_group[count.index]
  port             = 8500
}

# Creates a Target Group resource for use with ALB resources
resource "aws_lb_target_group" "jenkins-server-tg" {
  name        = "jenkins-server"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
      port     = 8080
      protocol = "HTTP"
  }

  # tags = {
  #   Name = "jenkins-server-tg"
  # }
}

# Creates a listner for ALB using http 
resource "aws_lb_listener" "jenkins-server-listner" {
  load_balancer_arn = aws_lb.private-resources-alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins-server-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "jenkins_server" {
  count            = 1
  target_group_arn = aws_lb_target_group.jenkins-server-tg.arn
  target_id        = var.jenkins_server_target_group[count.index]
  port             = 8080
}

# Creates a Target Group resource for use with ALB resources
resource "aws_lb_target_group" "prometheus-server-tg" {
  name        = "prometheus-server"
  port        = 9090
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
      port     = 9090
      protocol = "HTTP"
  }

  # tags = {
  #   Name = "prometheus-server-tg"
  # }
}

# Creates a listner for ALB using http 
resource "aws_lb_listener" "prometheus-server-listner" {
  load_balancer_arn = aws_lb.private-resources-alb.arn
  port              = 9090
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus-server-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "prometheus_server" {
  count            = 1
  target_group_arn = aws_lb_target_group.prometheus-server-tg.arn
  target_id        = var.prometheus_server_target_group[count.index]
  port             = 9090
}

# Creates a Target Group resource for use with ALB resources
resource "aws_lb_target_group" "grafana-server-tg" {
  name        = "grafana-server"
  port        = 3000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
      port     = 3000
      protocol = "HTTP"
      # path     = "/api/health"
  }

  # tags = {
  #   Name = "grafana-server-tg"
  # }
}

# Creates a listner for ALB using http 
resource "aws_lb_listener" "grafana-server-listner" {
  load_balancer_arn = aws_lb.private-resources-alb.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana-server-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "grafana_server" {
  count            = 1
  target_group_arn = aws_lb_target_group.grafana-server-tg.arn
  target_id        = var.grafana_server_target_group[count.index]
  port             = 3000
}

# Creates a Target Group resource for use with ALB resources
resource "aws_lb_target_group" "elk-server-tg" {
  name        = "elk-server"
  port        = 5601
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
      port     = 5601
      protocol = "HTTP"
  }

  # tags = {
  #   Name = "elk-server-tg"
  # }
}

# Creates a listner for ALB using http 
resource "aws_lb_listener" "elk-server-listner" {
  load_balancer_arn = aws_lb.private-resources-alb.arn
  port              = 5601
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elk-server-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "elk_server" {
  count            = 1
  target_group_arn = aws_lb_target_group.elk-server-tg.arn
  target_id        = var.elk_server_target_group[count.index]
  port             = 5601
}