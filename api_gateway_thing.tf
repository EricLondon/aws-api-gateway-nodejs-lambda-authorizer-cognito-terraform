resource "aws_api_gateway_integration" "api_integration_thing" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.api_lambda_thing.invoke_arn}"
}

resource "aws_api_gateway_integration" "api_integration_thing_root" {
  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.api_lambda_thing.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_thing_deployment" {
  depends_on = [
    "aws_api_gateway_integration.api_integration_thing",
    "aws_api_gateway_integration.api_integration_thing_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.example_api.id}"
  stage_name  = "thing"
}

output "api_gateway_thing_base_url" {
  value = "${aws_api_gateway_deployment.api_thing_deployment.invoke_url}"
}
