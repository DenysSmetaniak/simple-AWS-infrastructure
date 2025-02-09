# resource "aws_instance" "efs_setup_instance" {
#   ami                         = var.ec2_ami
#   instance_type               = var.ec2_instance_type
#   subnet_id                   = module.vpc.public_subnets[0]
#   iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
#   security_groups             = [aws_security_group.tm_devops_trainee_ec2_sg.id]
#   associate_public_ip_address = true
#
#   user_data = <<-EOF
#     #!/bin/bash
#     set -ex
#     sudo apt update -y
#     sudo apt install -y nfs-common amazon-ssm-agent
#
#     sudo systemctl enable amazon-ssm-agent
#     sudo systemctl start amazon-ssm-agent
#
#     sudo mkdir -p /mnt/efs
#
#     sudo mount -t nfs4 ${module.efs.id}.efs.${var.aws_region}.amazonaws.com:/ /mnt/efs
#
#     echo "Hello, Techmagic!" | sudo tee /mnt/efs/index.html
#
#     sudo systemctl status amazon-ssm-agent
#   EOF
#
#   tags = {
#     Name        = "efs-setup-instance"
#     Environment = "Test"
#   }
# }
#
# resource "aws_security_group" "tm_devops_trainee_ec2_sg" {
#   vpc_id = module.vpc.vpc_id
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = {
#     Name = "tm-devops-trainee-ec2-sg"
#   }
# }
#
#
# resource "aws_iam_role" "ec2_ssm_role" {
#   name = "EC2SSMRole"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect    = "Allow"
#       Principal = { Service = "ec2.amazonaws.com" }
#       Action    = "sts:AssumeRole"
#     }]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
#   role       = aws_iam_role.ec2_ssm_role.name
#   policy_arn = var.policy_arn
# }
#
# resource "aws_iam_instance_profile" "ec2_ssm_profile" {
#   name = var.name_iam_instance_profile
#   role = aws_iam_role.ec2_ssm_role.name
# }



