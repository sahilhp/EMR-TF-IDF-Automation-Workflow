output "emr_serverless_app_id" {
  description = "The ID of the EMR Serverless application."
  value       = aws_emrserverless_application.tfidf_app.id
}

output "emr_serverless_execution_role_arn" {
  description = "The ARN of the IAM role for job execution."
  value       = aws_iam_role.emr_serverless_execution_role.arn
}

output "s3_script_uri" {
  description = "The S3 URI for the PySpark job script."
  value       = "s3://${aws_s3_bucket.emr_studio_assets.bucket}/${aws_s3_object.script_file.key}"
}

output "s3_data_uri" {
  description = "The S3 URI for the input data file."
  value       = "s3://${aws_s3_bucket.emr_studio_assets.bucket}/${aws_s3_object.data_file.key}"
}
