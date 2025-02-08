terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "terraform"
  region  = "eu-central-1"
}

resource "aws_resourcegroups_group" "my_group" {
  name = "tm-devops-trainee-rg"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "Environment",
      "Values": ["Test"]
    }
  ]
}
JSON
  }

  tags = {
    Name        = "tm-devops-trainee-rg"
    Environment = "Test"
    Project     = "DevOps-Trainee"
    ManagedBy   = "Terraform"
    Owner       = "Denys Smetaniak"
  }
}





