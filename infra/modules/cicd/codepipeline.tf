resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.name}-codepipeline-artifacts-${var.server-name}-${var.environment}"
}

resource "aws_codepipeline" "this" {
  name     = "${var.name}-staging-${var.server-name}"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Image"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = aws_ecr_repository.this.name
      }
    }
  }

  stage {
  name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeployToECS"
      version          = "1"
      input_artifacts  = ["source"]

      configuration = {
        ApplicationName = aws_codedeploy_app.this.name
        DeploymentGroupName = aws_codedeploy_deployment_group.this.deployment_group_name
        TaskDefinitionTemplateArtifact = ""
        
      }
    }
  }

}