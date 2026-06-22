terraform {
  backend "s3" {
    bucket         = ""
    key            = "bootstrap/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}