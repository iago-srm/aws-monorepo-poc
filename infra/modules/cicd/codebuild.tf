resource "aws_s3_bucket" "build_cache" {
  bucket = "${var.name}-build-cache"
  force_destroy = true
  tags = var.tags
}

resource "aws_codebuild_project" "this" {
  name          = "${var.name}"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    # type = "CODEPIPELINE"
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
      value = "${var.project-name}/${var.server-name}"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.name}-build-log-group"
      stream_name = "${var.name}-build-log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.build_cache.id}/build-log"
    }
  }

  source {
    type = "GITHUB"
    # type            = "CODEPIPELINE"
    location        = "${var.git_repo}"
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
      pattern = "staging"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "packages/${var.server-name}"
    }
  }
}