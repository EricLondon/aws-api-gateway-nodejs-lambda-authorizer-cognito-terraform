resource "aws_api_gateway_integration" "api_integration_stuff" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.api_lambda_stuff.invoke_arn}"
}

resource "aws_api_gateway_integration" "api_integration_stuff_root" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.api_lambda_stuff.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_stuff_deployment" {
  depends_on = [
    "aws_api_gateway_integration.api_integration_stuff",
    "aws_api_gateway_integration.api_integration_stuff_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  stage_name  = "stuff"
}

output "api_gateway_stuff_base_url" {
  value = "${aws_api_gateway_deployment.api_stuff_deployment.invoke_url}"
}
