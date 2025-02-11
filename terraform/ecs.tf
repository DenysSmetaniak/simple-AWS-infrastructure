resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = var.ecs_cluster_setting_name
    value = var.ecs_cluster_setting_value
  }

  tags = merge(var.default_tags, {
    Name = var.ecs_cluster_name
  })
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.default_tags, {
    Name = var.ecs_task_execution_role_name
  })
}

resource "aws_iam_policy" "ecs_task_execution_role_policy" {
  name        = var.ecs_task_execution_role_policy_name
  path        = "/"
  description = "Allow ECS tasks to access AWS services"
  policy      = data.aws_iam_policy_document.task_execution_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_ssm" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_ecs_task_definition" "ecs_nginx_task" {
  family                   = var.ecs_nginx_task_family
  network_mode             = var.ecs_nginx_task_nm
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_nginx_task_cpu
  memory                   = var.ecs_nginx_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name       = "nginx-container"
      image      = "nginx:latest"
      essentials = true
      cpu        = 256
      memory     = 512
      # command = ["nginx", "-g", "daemon off;"]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      # user = "101:101"
      # filesystemReadonly = false

      mountPoints = [
        {
          sourceVolume  = "efs-volume"
          containerPath = "/usr/share/nginx/html"
          readOnly      = false
        }
      ]

      volumes = [
        {
          name = "efs-volume"
          efsVolumeConfiguration = {
            file_system_id     = module.efs.id
            root_directory     = "/"
            transit_encryption = "ENABLED"
            authorizationConfig = {
              access_point_id = aws_efs_access_point.efs_access_point.id
              iam             = "ENABLED"
            }
          }
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/aws/ecs/nginx-service"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  volume {
    name = "efs-volume"
    efs_volume_configuration {
      file_system_id     = module.efs.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
    }
  }

  depends_on = [aws_efs_access_point.efs_access_point]
}


resource "aws_ecs_service" "ecs_nginx_service" {
  name            = var.ecs_nginx_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_nginx_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  enable_execute_command = true

  network_configuration {
    # subnets          = module.vpc.public_subnets
    subnets          = ["subnet-0241f21e3d4ad2ceb"]
    security_groups  = [aws_security_group.tm_devops_trainee_ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tm_devops_trainee_tg.arn
    container_name   = "nginx-container"
    container_port   = 80
  }

  depends_on = [
    aws_lb.tm_devops_trainee_alb,
    aws_lb_listener.tm_devops_trainee_http,
    aws_lb_listener.tm_devops_trainee_https,
    module.efs
  ]
}

data "aws_iam_policy_document" "task_execution_role_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "secretsmanager:GetSecretValue",
      "ssm:GetParameters",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "efs_access" {
  name        = var.efs_access
  description = "Policy to allow ECS access to EFS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientRootAccess"
      ]
      Resource = module.efs.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_efs_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.efs_access.arn
}











