resource "aws_s3_bucket" "tf_state_bucket" {
    bucket = "sm-tf-state-bucket-0"
}
resource "aws_s3_bucket_versioning" "tf_state_bucket_versioning" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
