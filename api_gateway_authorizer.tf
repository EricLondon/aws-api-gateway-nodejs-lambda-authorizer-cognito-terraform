resource "aws_api_gateway_authorizer" "api_gateway_lambda_authorizer" {
  name                   = "api_gateway_lamba_authorizer_${var.instance}"
  rest_api_id            = "${aws_api_gateway_rest_api.example_api.id}"
  authorizer_uri         = "${aws_lambda_function.api_lambda_authorizer.invoke_arn}"
  authorizer_credentials = "${aws_iam_role.api_gateway_authorizer_role.arn}"
  type                   = "TOKEN"
}

resource "aws_iam_role" "api_gateway_authorizer_role" {
  name = "api_gateway_authorizer_role_${var.instance}"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_authorizer_assume_role.json}"
}

data "aws_iam_policy_document" "lambda_authorizer_assume_role" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lambda_authorizer_invocation_policy" {
  name   = "lamda_authorizer_policy_${var.instance}"
  role   = "${aws_iam_role.api_gateway_authorizer_role.id}"
  policy = "${data.aws_iam_policy_document.lambda_authorizer_invocation_policy_document.json}"
}

data "aws_iam_policy_document" "lambda_authorizer_invocation_policy_document" {
  statement {
    sid = ""
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      "${aws_lambda_function.api_lambda_authorizer.arn}"
    ]
  }
}
