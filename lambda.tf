resource "aws_iam_role" "state_notify_role" {
  name = "tf_state_alert_role_${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_role_policy" "state_notify_policy" {
  name = "tf_state_alert_policy_${terraform.workspace}"
  role = aws_iam_role.state_notify_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_lambda_function" "s3_notifier" {
  filename      = "lambda/s3_notifier.zip"
  function_name = "s3-upload-notifier_${terraform.workspace}"
  role          = aws_iam_role.state_notify_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"

environment {
  variables = {
    SENDER_EMAIL   = aws_ses_email_identity.email.email
    RECEIVER_EMAIL = "alaamagdy3008@gmail.com"
    region = var.region
  }
}
}


resource "aws_s3_bucket_notification" "state_trigger" {
  count  = terraform.workspace == "dev" ? 1 : 0
  bucket = "my-terraform-bucket-forlab2"

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_notifier.arn
    events              = ["s3:ObjectCreated:*"]

    filter_prefix = "terraform/state"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  count  = terraform.workspace == "dev" ? 1 : 0
  statement_id  = "AllowS3InvokeFromBackend"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_notifier.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::my-terraform-bucket-forlab2"
}  