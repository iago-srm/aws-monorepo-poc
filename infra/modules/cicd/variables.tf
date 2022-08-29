variable "tags" {
  type = map(string)
}

variable "project-name" {
  type = string
}

variable "name" {
  type = string
}

variable "server-name" {
  type = string
}

variable "git_repo" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
  default = ""
}

variable "alb_listener_http_arn" {
  type = string
}

variable "alb_listener_https_arn" {
  type = string
}

variable "tg_blue_name" {
  type = string
  default = ""
}

variable "tg_green_name" {
  type = string
  default = ""
}

