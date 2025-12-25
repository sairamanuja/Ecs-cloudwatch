# ==============================================================================
# APPLICATION LOAD BALANCER
# ==============================================================================
resource "aws_lb" "strapi" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.a.id, aws_subnet.b.id]

  enable_deletion_protection = false
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# ==============================================================================
# TARGET GROUP - BLUE (Production)
# ==============================================================================
resource "aws_lb_target_group" "blue" {
  name        = "${var.project_name}-tg-blue"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    path                = "/_health"
    protocol            = "HTTP"
    matcher             = "200,204"
  }

  deregistration_delay = 30

  tags = {
    Name = "${var.project_name}-tg-blue"
  }
}

# ==============================================================================
# TARGET GROUP - GREEN (New Deployment)
# ==============================================================================
resource "aws_lb_target_group" "green" {
  name        = "${var.project_name}-tg-green"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    path                = "/_health"
    protocol            = "HTTP"
    matcher             = "200,204"
  }

  deregistration_delay = 30

  tags = {
    Name = "${var.project_name}-tg-green"
  }
}

# ==============================================================================
# ALB LISTENER - PRODUCTION (Port 80)
# ==============================================================================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  tags = {
    Name = "${var.project_name}-listener-http"
  }

  # CodeDeploy will manage traffic shifting between Blue and Green
  lifecycle {
    ignore_changes = [default_action]
  }
}

# ==============================================================================
# ALB LISTENER - TEST (Port 8080) - For testing new deployments
# ==============================================================================
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  tags = {
    Name = "${var.project_name}-listener-test"
  }

  # CodeDeploy will manage this listener
  lifecycle {
    ignore_changes = [default_action]
  }
}

# ==============================================================================
# SECURITY GROUP FOR ALB
# ==============================================================================
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # HTTP from internet
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from internet (for future use)
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Test listener port for Blue/Green deployment
  ingress {
    description = "Test listener for Blue/Green deployment"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}
