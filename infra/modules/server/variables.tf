variable "tags" {
  type = map(string)
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "alb_arn" {
  type = string
}

variable "server-name" {
  type = string
}


variable "acm_validation_arn" {
  type = string
  default = "7"
}

variable "cluster_id" {
  type = string
}

variable "container_image" { 
  type = string
}


variable "container_port" { 
  type = number
  default = 3006
}

variable "alb_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}
