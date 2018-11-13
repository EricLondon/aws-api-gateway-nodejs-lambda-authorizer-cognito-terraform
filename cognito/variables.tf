
variable "aws_region" {
  type    = "string"
  default = "us-east-1"
}

variable "aws_profile" {
  type    = "string"
  default = ""
}

variable "aws_credentials_file" {
  type    = "string"
  default = "~/.aws/credentials"
}

variable "instance" {
  type    = "string"
  default = ""
}
