resource "aws_sqs_queue" "auth-domain-deadletter_queue" {
  name = "auth-domain-deadletter_queue"
  tags = var.tags
}

resource "aws_sqs_queue" "auth-domain-queue" {
  name                      = "auth-domain-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.auth-domain-deadletter_queue.arn
    maxReceiveCount     = 4
  })

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.auth-domain-deadletter_queue.arn]
  })

  tags = var.tags
}

output "queue_url" {
  value = aws_sqs_queue.auth-domain-queue.url
}