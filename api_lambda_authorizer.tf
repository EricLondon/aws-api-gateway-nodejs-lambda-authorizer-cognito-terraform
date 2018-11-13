resource "aws_lambda_function" "api_lambda_authorizer" {
  filename         = "api_lambda_authorizer.zip"
  function_name    = "api_lambda_authorizer_${var.instance}"
  role             = "${aws_iam_role.api_lambda_authorizer_role.arn}"
  handler          = "lambda_authorizer.handler"
  source_code_hash = "${data.archive_file.api_lambda_authorizer_zip.output_base64sha256}"
  runtime          = "nodejs8.10"

  environment {
    variables = {
      AWS_ACCOUNT_ID     = "${data.aws_caller_identity.current.account_id}"
      S3_BUCKET          = "${aws_s3_bucket.s3_bucket.id}"
      COGNITO_USER_POOL  = "${var.cognito_user_pool_id}"
    }
  }
}

data "archive_file" "api_lambda_authorizer_zip" {
  type        = "zip"
  output_path = "api_lambda_authorizer.zip"
  source_dir = "lambda_authorizer/"
}

resource "aws_iam_role" "api_lambda_authorizer_role" {
  name               = "api_lambda_authorizer_role_${var.instance}"
  assume_role_policy = "${data.aws_iam_policy_document.api_lambda_authorizer_assume_role.json}"
}

data "aws_iam_policy_document" "api_lambda_authorizer_assume_role" {
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

resource "aws_iam_role_policy_attachment" "api_lambda_authorizer_attach_policy" {
  role       = "${aws_iam_role.api_lambda_authorizer_role.name}"
  policy_arn = "${aws_iam_policy.api_lambda_authorizer_policy.arn}"
}

resource "aws_iam_policy" "api_lambda_authorizer_policy" {
  name   = "api_lambda_authorizer_policy_${var.instance}"
  policy = "${data.aws_iam_policy_document.api_lambda_authorizer_policy_document.json}"
}

data "aws_iam_policy_document" "api_lambda_authorizer_policy_document" {
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
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.api_lambda_authorizer.function_name}:*"
    ]
  }

  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}",
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
  }

}
