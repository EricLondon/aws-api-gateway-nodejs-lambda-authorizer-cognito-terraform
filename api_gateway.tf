
resource "aws_api_gateway_rest_api" "example_api" {
  name = "API-Gateway-${var.instance}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.example_api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"

  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.api_gateway_lambda_authorizer.id}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.example_api.root_resource_id}"
  http_method   = "ANY"

  authorization = "CUSTOM"
  authorizer_id = "${aws_api_gateway_authorizer.api_gateway_lambda_authorizer.id}"
}
