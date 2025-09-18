# IAM Role for EMR Serverless Execution
resource "aws_iam_role" "emr_serverless_execution_role" {
  name               = "EMR-Serverless-Execution-Role-TFIDF"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "emr-serverless.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "emr_serverless_policy" {
  name = "EMR-Serverless-S3-Log-Policy"
  role = aws_iam_role.emr_serverless_execution_role.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          aws_s3_bucket.emr_studio_assets.arn,
          "${aws_s3_bucket.emr_studio_assets.arn}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM Role for EMR Studio User Access
resource "aws_iam_role" "emr_studio_service_role" {
  name               = "EMR-Studio-Service-Role-TFIDF"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "elasticmapreduce.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "emr_studio_service_policy" {
  role       = aws_iam_role.emr_studio_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEMRStudioServiceRolePolicy"
}
