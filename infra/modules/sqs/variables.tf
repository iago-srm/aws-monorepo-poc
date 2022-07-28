variable "tags" {
  type = map(string)
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "env_api_url" {
  type = string
}

variable "lambda-bucket_name" {
  type = string
  default = "lambda-bucket-asdsadadadasda"
}