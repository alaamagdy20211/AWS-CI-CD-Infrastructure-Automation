variable "region" {
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  default = "my-terraform-bucket-forlab2"
}

variable "lock_table_name" {
  type        = string
  default     = "terraform-lock-table"
}