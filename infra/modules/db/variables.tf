variable "tags" {
  type = map(string)
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "db_password" {
  type = string
}

variable "db_user" {
  type = string
  default = "postgres"
}
