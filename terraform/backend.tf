terraform {
  backend "s3" {
    bucket         = var.bucket
    key            = var.bucket_key
    region         = var.aws_region
    dynamodb_table = var.dynamodb_table_name
    encrypt        = true
  }
}

data "aws_dynamodb_table" "tm_devops_trainee_table" {
  name = var.dynamodb_table_name
}

