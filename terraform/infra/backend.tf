terraform {
  backend "s3" {
    bucket         = "my-terraform-bucket-forlab2"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"

  }
}