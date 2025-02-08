terraform {
  backend "s3" {
    bucket         = "tm-devops-trainee-bucket"
    key            = "terraform/state/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tm-devops-trainee-table"
    encrypt        = true
  }
}

resource "aws_dynamodb_table" "tm_devops_trainee_table" {
  name         = "tm-devops-trainee-table"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "tm-devops-trainee-table"
    Environment = "Test"
    Project     = "DevOps-Trainee"
    ManagedBy   = "Terraform"
    Owner       = "Denys Smetaniak"
  }
}