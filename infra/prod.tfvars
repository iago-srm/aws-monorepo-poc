variable "tags" {
  type = map(string)
  default = {
    Project     = "aws-monorepo-poc"
    Environment = "prod"
  }
}