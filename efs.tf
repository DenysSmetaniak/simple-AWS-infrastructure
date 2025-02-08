module "efs" {
  source = "terraform-aws-modules/efs/aws"

  name           = var.efs_name
  creation_token = var.efs_creation_token
  encrypted      = true

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }

  mount_targets = {
    "eu-central-1a" = {
      subnet_id = module.vpc.private_subnets[0]
    }
    "eu-central-1b" = {
      subnet_id = module.vpc.private_subnets[1]
    }
  }

  security_group_vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ecs_access = {
      description              = "Allow NFS from ECS security group"
      source_security_group_id = aws_security_group.tm_devops_trainee_ecs_sg.id
    }
  }

  enable_backup_policy = true

  tags = merge(var.default_tags, {
    Name = var.efs_name
  })
}

# Access point for EFS
resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = module.efs.id

  root_directory {
    path = "/"
    creation_info {
      owner_uid   = 1001
      owner_gid   = 1001
      permissions = "755"
    }
  }

  tags = {
    Name = "tm-devops-trainee-efs-ap"
  }
}

output "efs_access_point_id" {
  value = aws_efs_access_point.efs_access_point.id
}


resource "aws_iam_policy" "efs_access" {
  name        = var.efs_iam_policy_name
  description = "Policy to allow EC2 access to EFS"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:DescribeMountTargets",
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:ClientRootAccess"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "efs_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.efs_access.arn
}


# # Amazon EFS
# resource "aws_efs_file_system" "tm_devops_trainee_efs" {
#   creation_token = "tm-devops-trainee-efs"
#
#   tags = {
#     Name        = "tm-devops-trainee-efs"
#     Environment = "Test"
#     Project     = "DevOps-Trainee"
#     ManagedBy   = "Terraform"
#     Owner       = "Denys Smetaniak"
#   }
# }
#
# # EFS Mount Targets
# resource "aws_efs_mount_target" "tm_devops_trainee_efs_mount" {
#   for_each = toset(module.vpc.private_subnets)
#
#   file_system_id  = aws_efs_file_system.tm_devops_trainee_efs.id
#   subnet_id       = each.value
#   security_groups = [aws_security_group.tm_devops_trainee_efs_sg.id]
# }



