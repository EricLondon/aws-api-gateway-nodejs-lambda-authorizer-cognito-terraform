resource "aws_cognito_user_pool" "user_pool" {
  name = "users-${var.instance}"

  schema {
    name                     = "acl_thing"
    attribute_data_type      = "String"
    mutable                  = true
    developer_only_attribute = false
  }

  schema {
    name                     = "acl_stuff"
    attribute_data_type      = "String"
    mutable                  = true
    developer_only_attribute = false
  }
}

resource "aws_cognito_user_pool_client" "example_client" {
  name = "client_${var.instance}"
  user_pool_id = "${aws_cognito_user_pool.user_pool.id}"
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  read_attributes = ["name", "email", "sub", "custom:acl_thing", "custom:acl_stuff"]
}

output "cognito_user_pool_id" {
  value = "${aws_cognito_user_pool.user_pool.id}"
}

output "cognito_client" {
  value = "${aws_cognito_user_pool_client.example_client.id}"
}
