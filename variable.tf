////////////////// Variable for VPC /////////////////

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "tm-devops-trainee-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to be used in the VPC"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway for the VPC"
  type        = bool
  default     = false
}

////////////////// Variable for tags /////////////////

variable "default_tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    Environment = "Test"
    Project     = "DevOps-Trainee"
    ManagedBy   = "Terraform"
    Owner       = "Denys Smetaniak"
  }
}

variable "aws_region" {
  default = "eu-central-1"
}

////////////////// Variable for SG /////////////////



////////////////// Variable for TG /////////////////

variable "tg_name" {
  description = "The name of the target group"
  type        = string
  default     = "tm-devops-trainee-tg"
}

variable "tg_port" {
  description = "The port for the target group"
  type        = number
  default     = 80
}

variable "tg_protocol" {
  description = "The protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "tg_target_type" {
  description = "The target type for the target group"
  type        = string
  default     = "ip"
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold for health check"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for health check"
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "Health check matcher"
  type        = string
  default     = "200"
}

////////////////// Variable for ECS /////////////////

variable "cluster_name" {
  type = string
  default = "tm-devops-trainee-ecs"
}

variable "nginx_service_cpu" {
  type = number
  default = 256
}

variable "nginx_service_memory" {
  type = number
  default = 512
}

variable "cd_nginx_cpu" {
  type = number
  default = 256
}

variable "cd_nginx_memory" {
  type = number
  default = 512
}

////////////////// Variable for EC2 /////////////////

variable "ec2_ami" {
  type = string
  default = "ami-03b3b5f65db7e5c6f"
}

variable "ec2_instance_type" {
  type = string
  default = "t2.micro"
}

variable "policy_arn" {
  type = string
  default = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

variable "name_iam_instance_profile" {
  type = string
  default = "EC2SSMInstanceProfile"
}

////////////////// Variable for EFC /////////////////

variable "efs_name" {
  type = string
  default = "tm-devops-trainee-efs"
}

variable "efs_creation_token" {
  type = string
  default = "tm-devops-trainee-efs-token"
}

variable "efs_iam_policy_name" {
  type = string
  default = "EFSFullAccess"
}

////////////////// Variable for ALB /////////////////

variable "alb_name" {
  type = string
  default = "tm-devops-trainee-alb"
}

variable "lb_type" {
  type = string
  default = "application"
}

variable "listener_ssl_policy" {
  type = string
  default = "ELBSecurityPolicy-2016-08"
}

variable "certificate_arn" {
  description = "ARN of the TLS certificate"
  type = string
  sensitive   = true
}

