///////////////////////////// Target group for ECS ///////////////////////////

resource "aws_lb_target_group" "tm_devops_trainee_tg" {
  name        = var.tg_name
  port        = var.tg_port
  protocol    = var.tg_protocol
  vpc_id      = module.vpc.vpc_id
  target_type = var.tg_target_type

  health_check {
    path                = "/"
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  tags = merge(var.default_tags, {
    Name = var.tg_name
  })
}



