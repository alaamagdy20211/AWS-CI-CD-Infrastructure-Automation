resource "aws_ses_email_identity" "email" {
  email = var.notification_email
}