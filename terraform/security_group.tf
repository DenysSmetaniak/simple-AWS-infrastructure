///////////////////////////// Security Group for ALB ///////////////////////////

resource "aws_security_group" "tm_devops_trainee_alb_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, {
    Name = var.vpc_name
  })
}

///////////////////////////// Security Group for ECS ///////////////////////////

resource "aws_security_group" "tm_devops_trainee_ecs_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "ecs-sg"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.tm_devops_trainee_alb_sg.id] # We allow traffic only from ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, {
    Name = var.vpc_name
  })
}

///////////////////////////// Security Group для EFS ///////////////////////////

resource "aws_security_group" "tm_devops_trainee_efs_sg" {
  name        = "efs-sg"
  description = "Allow NFS traffic from ECS only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow NFS traffic from ECS only"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.tm_devops_trainee_ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, {
    Name = var.vpc_name
  })
}
