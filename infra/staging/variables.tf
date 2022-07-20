variable "tags" {
  type = map(string)
  default = {
    Project     = "aws-monorepo-poc"
    Environment = "staging"
  }
}

variable "name" {
  type    = string
  default = "aws-monorepo-poc"
}

variable "environment" {
  type    = string
  default = "staging"
}