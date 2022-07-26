# resource "aws_codestarconnections_connection" "this" {
#   name          = "aws-monorepo-poc-connection"
#   provider_type = "GitHub"
# }

# resource "aws_codepipeline" "this" {
#   name     = "example-pipeline"
#   role_arn = "${aws_iam_role.pipeline.arn}"

#   artifact_store {
#     location = "${aws_s3_bucket.this.bucket}"
#     type     = "S3"
#   }

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "CodeStarSourceConnection"
#       version          = "1"
#       output_artifacts = ["source"]

#       configuration = {
#         FullRepositoryId = "iago-srm/aws-monorepo-poc"
#         ConnectionArn = aws_codestarconnections_connection.this.arn
#         BranchName     = "develop"
#       }
#     }
#   }

#   stage {
#   name = "Build"

#     action {
#         name             = "Build"
#         category         = "Build"
#         owner            = "AWS"
#         provider         = "CodeBuild"
#         version          = "1"
#         input_artifacts  = ["source"]
#         output_artifacts = ["build"]

#         configuration {
#             ProjectName = aws_codebuild_project.this.name
#         }
#     }
#   }

# }