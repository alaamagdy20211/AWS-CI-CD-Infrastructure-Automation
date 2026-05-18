terraform {
  backend "s3" {
    bucket         = "my-terraform-bucket-forlab2"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}