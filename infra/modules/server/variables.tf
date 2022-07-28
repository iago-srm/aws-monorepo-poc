variable "tags" {
  type = map(string)
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "server-name" {
  type = string
}

variable "alb_listener_arn" {
  type = string
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

variable "env_database_url" {
  type = string
}

variable "env_queue_url" {
  type = string
  default = ""
}

variable "env_bucket_name" {
  type = string
  default = ""
}
