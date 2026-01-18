############################################################
# Terraform module: Placeholder AWS Lambda function
#
# Creates a Lambda function using a tiny inline handler so
# environments can provision a function before real code.
############################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4"
    }
  }
}

data "archive_file" "package" {
  type        = "zip"
  source_file = "${path.module}/placeholder/index.py"
  output_path = "${path.module}/placeholder.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  description      = var.description
  role             = var.role_arn
  runtime          = var.runtime
  handler          = var.handler
  filename         = data.archive_file.package.output_path
  source_code_hash = data.archive_file.package.output_base64sha256
  memory_size      = var.memory_size
  timeout          = var.timeout
  publish          = var.publish
  tags             = var.tags

  dynamic "environment" {
    for_each = length(var.environment) > 0 ? [1] : []
    content {
      variables = var.environment
    }
  }
}
