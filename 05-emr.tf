resource "aws_emrserverless_application" "tfidf_app" {
  name          = "tfidf-wikipedia-app"
  release_label = "emr-6.15.0"
  type          = "SPARK"

  auto_start_configuration {
    enabled = true
  }

  auto_stop_configuration {
    enabled              = true
    idle_timeout_minutes = 15
  }
}

resource "aws_emr_studio" "tfidf_studio" {
  name                        = "TFIDF-Studio"
  auth_mode                   = "IAM"
  vpc_id                      = aws_vpc.emr_studio_vpc.id
  subnet_ids                  = aws_subnet.emr_studio_subnet[*].id
  service_role                = aws_iam_role.emr_studio_service_role.arn
  default_s3_location         = "s3://${aws_s3_bucket.emr_studio_assets.bucket}/emr-studio/"
  engine_security_group_id    = aws_security_group.emr_studio_sg.id
  workspace_security_group_id = aws_security_group.emr_studio_sg.id
}
