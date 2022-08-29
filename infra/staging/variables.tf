variable "tags" {
  type = map(string)
  default = {
    Project     = "aws-monorepo-poc"
    Environment = "staging"
  }
}

variable "name" {
  type    = string
}

variable "github_repo" {
  type    = string
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "db_password" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "api_url" {
  type = string
}

variable "admin_ip" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "microsservices" {
  description = "The microsservices in this architecture"
  type = list(string)
  default = ["api-1", "api-2"]
}