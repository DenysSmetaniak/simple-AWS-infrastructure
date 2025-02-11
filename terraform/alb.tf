# # Application Load Balancer (ALB)
resource "aws_lb" "tm_devops_trainee_alb" {
  name                       = var.alb_name
  internal                   = false
  load_balancer_type         = var.lb_type
  security_groups            = [aws_security_group.tm_devops_trainee_alb_sg.id]
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false

  tags = merge(var.default_tags, {
    Name = var.alb_name
  })
}

resource "aws_lb_listener" "tm_devops_trainee_http" {
  load_balancer_arn = aws_lb.tm_devops_trainee_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "tm_devops_trainee_https" {
  load_balancer_arn = aws_lb.tm_devops_trainee_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.listener_ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tm_devops_trainee_tg.arn
  }
}

# module "alb" {
#   source = "terraform-aws-modules/alb/aws"
#
#   name               = "tm-devops-trainee-alb"
#   internal           = false
#   load_balancer_type = "application"
#   vpc_id             = module.vpc.vpc_id
#   subnets            = module.vpc.public_subnets
#   security_groups    = [aws_security_group.tm_devops_trainee_alb_sg.id]
#
#   enable_deletion_protection       = false
#   enable_cross_zone_load_balancing = true
#   enable_http2                     = true
#
#   # ALB logs
#   access_logs = {
#     bucket  = "tm-devops-trainee-alb-logs"
#     prefix  = "alb-logs"
#     enabled = true
#   }
#
#   listeners = {
#     http-redirect = {
#       port     = 80
#       protocol = "HTTP"
#
#       default_action = {
#         type = "redirect"
#
#         redirect = {
#           port        = 443
#           protocol    = "HTTPS"
#           status_code = "HTTP_301"
#         }
#       }
#     }
#     https = {
#       port            = 443
#       protocol        = "HTTPS"
#       certificate_arn =
#
#       default_action = {
#         type             = "forward"
#         target_group_arn = aws_lb_target_group.tm_devops_trainee_tg.arn
#       }
#     }
#   }
#
# }















