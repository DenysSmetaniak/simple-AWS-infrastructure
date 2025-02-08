data "aws_s3_bucket" "my_bucket" {
  bucket = "tm-devops-trainee-bucket"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = data.aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}



