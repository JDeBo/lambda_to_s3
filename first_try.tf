variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
  default = "us-east-2"
}
variable "lambda_function_name" {
  default = "first_try"
}
data "aws_iam_user" "terraform" {
  user_name = "terraform_lamda_s3"
}

terraform {
  backend "s3" {
    bucket         = "jd95-main-tfstate"
    key            = "state/lambda_s3.tfstate"
    region         = "us-east-2"
    dynamodb_table = "main-tfstatelock"
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

# resource "aws_iam_role" "iam_for_lambda" {
#   name = "iam_for_lambda"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#           "s3:GetObject"
#       ],
#       "Resource": "arn:aws:s3:::*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": "logs:CreateLogGroup",
#       "Resource": "arn:aws:logs:us-east-1:932196253170:*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#       ],
#       "Resource": [
#           "arn:aws:logs:us-east-1:932196253170:log-group:/aws/lambda/*"
#       ]
#     }
#   ]
# }
# EOF
# }

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_s3" {
  name        = "lambda_s3"
  path        = "/"
  description = "IAM policy for logging and s3 for lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Action": [
          "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}
resource "aws_lambda_function" "test_lambda" {
  filename      = "lamda-deploy_1.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "exports.test"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  # source_code_hash = filebase64sha256("lambda_deploy_1.zip")

  runtime = "python3.7"

  environment {
    variables = {
      foo = "bar"
    }
  }
}