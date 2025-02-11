terraform {
  backend "s3" {
    bucket         = "tm-devops-trainee-bucket"
    key            = "terraform/state/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tm-devops-trainee-table"
    encrypt        = true
  }
}

data "aws_dynamodb_table" "tm_devops_trainee_table" {
  name = "tm-devops-trainee-table"
}

