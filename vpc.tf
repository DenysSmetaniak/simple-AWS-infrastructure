module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = merge(var.default_tags, {
    Name = var.vpc_name
  })
}


# # VPC
# resource "aws_vpc" "tm_devops_trainee_vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true
#
# # Public Subnets
# resource "aws_subnet" "tm_devops_trainee_public_subnet" {
#   vpc_id                  = aws_vpc.tm_devops_trainee_vpc.id
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = true
#   availability_zone       = "us-east-1a"
#
# # Private Subnets
# resource "aws_subnet" "tm_devops_trainee_private_subnet" {
#   vpc_id                  = aws_vpc.tm_devops_trainee_vpc.id
#   cidr_block              = "10.0.2.0/24"
#   map_public_ip_on_launch = false
#   availability_zone       = "us-east-1b"
#
# # Internet Gateway
# resource "aws_internet_gateway" "tm_devops_trainee_igw" {
#   vpc_id = aws_vpc.tm_devops_trainee_vpc.id
#
#
# # Route Table for public subnets
# resource "aws_route_table" "tm_devops_trainee_public_rt" {
#   vpc_id = aws_vpc.tm_devops_trainee_vpc.id
#
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.tm_devops_trainee_igw.id
#   }
#
# # Binding Route Table to Public Subnet
# resource "aws_route_table_association" "tm_devops_trainee_public_assoc" {
#   subnet_id      = aws_subnet.tm_devops_trainee_public_subnet.id
#   route_table_id = aws_route_table.tm_devops_trainee_public_rt.id
# }




