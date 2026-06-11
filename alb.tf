resource "aws_lb" "app_alb" {
  name               = "application-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.web_sg.id]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  tags = {
    Name = "application-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"

  vpc_id = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app-target-group"
  }
}

# Attach EC2 to Target Group
resource "aws_lb_target_group_attachment" "web_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn

  target_id = aws_instance.web.id
  port      = 80
}

# Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}