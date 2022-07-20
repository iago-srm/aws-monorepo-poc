resource "aws_s3_bucket" "build_cache" {
  bucket = "${var.name}-build-cache-${var.server-name}-${var.environment}"
  tags = var.tags
}

resource "aws_codebuild_project" "this" {
  name          = "${var.name}-${var.server-name}-${var.environment}"
  build_timeout = "5"
  service_role  = aws_iam_role.this.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.build_cache.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "553239741950"
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "aws-monorepo-poc/${var.server-name}"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.server-name}-build-log-group-${var.environment}"
      stream_name = "${var.server-name}-build-log-stream-${var.environment}"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.build_cache.id}/build-log"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/iago-srm/aws-monorepo-poc.git"
    git_clone_depth = 1
    buildspec       = "packages/${var.server-name}/buildspec.yml"
  }

  tags = var.tags
}

resource "aws_codebuild_webhook" "example" {
  project_name = aws_codebuild_project.this.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "${var.environment}"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "packages/${var.server-name}"
    }
  }
}