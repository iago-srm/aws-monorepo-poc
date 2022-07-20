resource "aws_ecs_cluster" "this" {
  name = "${var.name}-ecs-cluster-${var.environment}"
}


output "cluster_id" {
  value = aws_ecs_cluster.this.id
}