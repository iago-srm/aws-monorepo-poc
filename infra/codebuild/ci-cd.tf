resource "aws_s3_bucket" "build_cache" {
  bucket = "${var.name}-build-cache-api-2"
}

resource "aws_codebuild_project" "api-2" {
  name          = "${var.name}-api-2-${var.environment}"
  build_timeout = "5"
  service_role  = aws_iam_role.api-2_codebuild.arn

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

  }

  logs_config {
    cloudwatch_logs {
      group_name  = "api-2-build-log-group"
      stream_name = "api-2-build-log-stream"
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
    buildspec       = "packages/api-2/buildspec.yml"
  }



  tags = var.tags
}

resource "aws_codebuild_webhook" "example" {
  project_name = aws_codebuild_project.api-2.name
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
      pattern = "packages/api-2"
    }
  }
}