resource "aws_ecr_repository" "this" {
  name                 = "${var.project-name}/${var.server-name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}