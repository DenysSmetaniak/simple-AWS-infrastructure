terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  #   profile = "terraform"
  region = var.aws_region
}

resource "aws_resourcegroups_group" "my_group" {
  name = var.rg_name

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

  tags = merge(var.default_tags, {
    Name = var.rg_name
  })
}









