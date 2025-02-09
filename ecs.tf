# module "ecs" {
#   source = "terraform-aws-modules/ecs/aws"
#
#   cluster_name = var.cluster_name
#
#   fargate_capacity_providers = {
#     FARGATE = {
#       default_capacity_provider_strategy = {
#         weight = 100
#       }
#     }
#   }
#
#   services = {
#     nginx_service = {
#       cpu    = var.nginx_service_cpu
#       memory = var.nginx_service_memory
#
#       enable_execute_command = true
#
#       task_execution_role = aws_iam_role.ecs_task_execution_role.arn
#
#       volumes = [
#         {
#           name = "efs-volume"
#           efs_volume_configuration = {
#             file_system_id     = module.efs.id
#             root_directory     = "/"
#             transit_encryption = "ENABLED"
#             authorization_config = {
#               access_point_id = aws_efs_access_point.efs_access_point.id
#               iam             = "ENABLED"
#             }
#           }
#         }
#       ]
#
#       container_definitions = {
#         nginx = {
#           cpu       = var.cd_nginx_cpu
#           memory    = var.cd_nginx_memory
#           essential = true
#           image     = "nginx:latest"
#           port_mappings = [
#             {
#               name          = "nginx"
#               containerPort = 80
#               protocol      = "tcp"
#             }
#           ]
#
#           readonly_root_filesystem = false
#
#           mount_points = [
#             {
#               source_volume  = "efs-volume"
#               container_path = "/usr/share/nginx/html"
#               read_only      = false
#             }
#           ]
#
#         }
#       }
#
#       load_balancer = {
#         service = {
#           target_group_arn = aws_lb_target_group.tm_devops_trainee_tg.arn
#           container_name   = "nginx"
#           container_port   = 80
#         }
#       }
#
#       subnet_ids      = module.vpc.private_subnets
#       security_groups = [aws_security_group.tm_devops_trainee_ecs_sg.id]
#
#       network_configuration = {
#         assign_public_ip = false # ECS using private subnets
#       }
#
#       security_group_rules = {
#         alb_ingress_80 = {
#           type                     = "ingress"
#           from_port                = 80
#           to_port                  = 80
#           protocol                 = "tcp"
#           description              = "Allow traffic from ALB"
#           source_security_group_id = aws_security_group.tm_devops_trainee_alb_sg.id
#         }
#         egress_all = {
#           type        = "egress"
#           from_port   = 0
#           to_port     = 0
#           protocol    = "-1"
#           cidr_blocks = ["0.0.0.0/0"]
#         }
#       }
#     }
#   }
#
#   depends_on = []
#
#   tags = merge(var.default_tags, {
#     Name = var.cluster_name
#   })
# }


# resource "aws_ecs_cluster" "tm_devops_trainee_ecs" {
#   name = "tm-devops-trainee-ecs"
#
#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
#
#   tags = {
#     Name        = "tm-devops-trainee-ecs"
#     Environment = "Test"
#     Project     = "DevOps-Trainee"
#     ManagedBy   = "Terraform"
#     Owner       = "Denys Smetaniak"
#   }
# }
#
# resource "aws_iam_role" "ecs_task_execution" {
#   name = "ecsTaskExecutionRole"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = { Service = "ecs-tasks.amazonaws.com" }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }
#
# resource "aws_iam_role_policy" "ecs_task_efs_access" {
#   name = "EFSAccessPolicy"
#   role = aws_iam_role.ecs_task_execution.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticfilesystem:ClientMount",
#           "elasticfilesystem:ClientWrite",
#           "elasticfilesystem:DescribeMountTargets"
#         ]
#         Resource = module.efs.arn
#       }
#     ]
#   })
# }
#
# resource "aws_iam_policy_attachment" "ecs_task_execution_policy" {
#   name       = "ecs-task-execution-policy"
#   roles      = [aws_iam_role.ecs_task_execution.name]
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
#
# resource "aws_ecs_task_definition" "nginx" {
#   family                   = "nginx_service"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = "256"
#   memory                   = "512"
#   execution_role_arn       = aws_iam_role.ecs_task_execution.arn
#   task_role_arn            = aws_iam_role.ecs_task_execution.arn
# #   enable_execute_command   = true
#
#   volume {
#     name = "efs-volume"
#     efs_volume_configuration {
#       file_system_id     = module.efs.id
#       root_directory     = "/"
#       transit_encryption = "ENABLED"
#
#       authorization_config {
#         access_point_id = aws_efs_access_point.efs_access_point.id
#         iam             = "ENABLED"
#       }
#     }
#   }
#
#   container_definitions = jsonencode([
#     {
#       name      = "nginx"
#       image     = "654654418834.dkr.ecr.eu-central-1.amazonaws.com/nginx-custom:latest"
#       cpu       = 256
#       memory    = 512
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           protocol      = "tcp"
#         }
#       ]
#       mountPoints = [
#         {
#           sourceVolume  = "efs-volume"
#           containerPath = "/usr/share/nginx/html"
#         }
#       ]
#       readonlyRootFilesystem = false
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group         = "/aws/ecs/nginx_service"
#           awslogs-region        = "eu-central-1"
#           awslogs-stream-prefix = "ecs"
#         }
#       }
#     }
#   ])
#
#   depends_on = [aws_cloudwatch_log_group.ecs_nginx, module.efs, aws_efs_access_point.efs_access_point]
# }
#
# # resource "aws_iam_role_policy_attachment" "ecs_ssm_policy" {
# #   role       = aws_iam_role.ecs_task_execution.name
# #   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# # }
#
#
# resource "aws_efs_access_point" "efs_access_point" {
#   file_system_id = module.efs.id
#   root_directory {
#     path = "/"
#     creation_info {
#       owner_uid   = 1001
#       owner_gid   = 1001
#       permissions = "755"
#     }
#   }
# }
#
# resource "aws_cloudwatch_log_group" "ecs_nginx" {
#   name              = "/aws/ecs/nginx_service"
#   retention_in_days = 30
# }
#
# resource "aws_ecs_service" "nginx_service" {
#   name            = "nginx_service"
#   cluster         = aws_ecs_cluster.tm_devops_trainee_ecs.id
#   task_definition = aws_ecs_task_definition.nginx.arn
#   desired_count   = 1
#
#   capacity_provider_strategy {
#     capacity_provider = "FARGATE_SPOT"
#     weight            = 1
#   }
#
#   depends_on = [aws_ecs_cluster.tm_devops_trainee_ecs]
#
#   network_configuration {
#     subnets          = module.vpc.private_subnets
#     security_groups  = [aws_security_group.tm_devops_trainee_ecs_sg.id]
#     assign_public_ip = false
#   }
#
#   load_balancer {
#     target_group_arn = aws_lb_target_group.tm_devops_trainee_tg.arn
#     container_name   = "nginx"
#     container_port   = 80
#   }
#
#   deployment_minimum_healthy_percent = 50
#   deployment_maximum_percent         = 200
#
#   lifecycle {
#     ignore_changes = [task_definition]
#   }
# }

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "tm-devops-trainee-cluster"

  tags = merge(var.default_tags, {
    Name = "tm-devops-trainee-cluster"
  })
}

resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name    = "nginx-container"
      image   = "nginx:latest"
      cpu     = 256
      memory  = 512
      command = ["nginx", "-g", "daemon off;"]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      user = "1000:1000"

      mountPoints = [
        {
          sourceVolume  = "efs-volume"
          containerPath = "/usr/share/nginx/html"
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/aws/ecs/nginx-service"
          awslogs-region        = "eu-central-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  volume {
    name = "efs-volume"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.efs.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.efs_access_point.id
        iam             = "ENABLED"
      }
    }
  }

  depends_on = [aws_efs_access_point.efs_access_point]
}


resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  enable_execute_command = true

  network_configuration {
    subnets          = module.vpc.public_subnets
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
    aws_efs_file_system.efs
  ]
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
    Name = "ecs-task-execution-role"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_efs_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name        = "ecs-exec-policy"
  description = "Allows ECS Exec functionality"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "ssm:TerminateSession"
        ],
        Resource = "arn:aws:ssm:*:*:session/*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy_attach" {
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}














