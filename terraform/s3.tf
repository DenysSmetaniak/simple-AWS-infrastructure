/////////////////// Import S3 for remote state file ///////////////////

data "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket
}

///////////////////////////// Versioning S3 ///////////////////////////

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = data.aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}



