resource "aws_lambda_function" "api_lambda_thing" {
  filename         = "api_lambda_thing.zip"
  function_name    = "api_lambda_thing_${var.instance}"
  role             = "${aws_iam_role.api_lambda_thing_role.arn}"
  handler          = "api_lambda_thing.handler"
  source_code_hash = "${data.archive_file.api_lambda_thing_zip.output_base64sha256}"
  runtime          = "nodejs8.10"

  environment {
    variables = {
      AWS_ACCOUNT_ID = "${data.aws_caller_identity.current.account_id}"
      S3_BUCKET      = "${aws_s3_bucket.s3_bucket.id}"
    }
  }
}

data "archive_file" "api_lambda_thing_zip" {
  type        = "zip"
  source_file = "api_lambda_thing.js"
  output_path = "api_lambda_thing.zip"
}

resource "aws_iam_role" "api_lambda_thing_role" {
  name = "api_lambda_thing_role_${var.instance}"
  assume_role_policy = "${data.aws_iam_policy_document.api_lambda_thing_assume_role.json}"
}

data "aws_iam_policy_document" "api_lambda_thing_assume_role" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "api_lambda_thing_policy_attach" {
  role = "${aws_iam_role.api_lambda_thing_role.name}"
  policy_arn = "${aws_iam_policy.api_lambda_thing_policy.arn}"
}

resource "aws_iam_policy" "api_lambda_thing_policy" {
  name   = "api_lambda_thing_policy_${var.instance}"
  policy = "${data.aws_iam_policy_document.api_lambda_thing_policy_document.json}"
}

data "aws_iam_policy_document" "api_lambda_thing_policy_document" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.api_lambda_thing.function_name}:*"
    ]
  }

  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject*"
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}",
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
  }

}

resource "aws_lambda_permission" "api_lambda_thing_api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.api_lambda_thing.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.api_thing_deployment.execution_arn}/*/*"
}
