///////////////////////////// EFS ///////////////////////////

module "efs" {
  source = "terraform-aws-modules/efs/aws"

  name           = var.efs_name
  creation_token = var.efs_creation_token
  encrypted      = true

  mount_targets = {
    "eu-central-1a" = {
      subnet_id       = module.vpc.private_subnets[0]
      security_groups = [aws_security_group.tm_devops_trainee_efs_sg.id]
    }
    "eu-central-1b" = {
      subnet_id       = module.vpc.private_subnets[1]
      security_groups = [aws_security_group.tm_devops_trainee_efs_sg.id]
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


# resource "aws_efs_file_system" "efs" {
#   creation_token   = "tm-devops-trainee-efs"
#   performance_mode = "generalPurpose"
#   throughput_mode  = "bursting"
#   encrypted        = true
#
#   lifecycle_policy {
#     transition_to_ia = "AFTER_30_DAYS"
#   }
#
#   tags = merge(var.default_tags, {
#     Name = "tm-devops-trainee-efs"
#   })
# }
#
# ////////////////////////////// Mount target EFS //////////////////////////
#
# resource "aws_efs_mount_target" "efs_mount_target" {
#   count           = length(module.vpc.private_subnets)
#   file_system_id  = aws_efs_file_system.efs.id
#   subnet_id       = element(module.vpc.private_subnets, count.index)
#   security_groups = [aws_security_group.tm_devops_trainee_efs_sg.id]
# }

///////////////////////////// Access point EFS ///////////////////////////

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = module.efs.id

  root_directory {
    path = "/"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "775"
    }
  }

  posix_user {
    uid = 1000
    gid = 1000
  }

  tags = merge(var.default_tags, {
    Name = "efs-access-point"
  })
}




