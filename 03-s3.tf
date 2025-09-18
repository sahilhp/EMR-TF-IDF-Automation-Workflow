# Use a random string to ensure the S3 bucket name is unique
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "emr_studio_assets" {
  bucket = "emr-studio-tfidf-assets-${random_string.bucket_suffix.result}"
}

# Upload all necessary files
resource "aws_s3_object" "data_file" {
  bucket = aws_s3_bucket.emr_studio_assets.id
  key    = "data/subset_small.tsv"
  source = "subset_small.tsv"
}

resource "aws_s3_object" "script_file" {
  bucket = aws_s3_bucket.emr_studio_assets.id
  key    = "scripts/tfidf_job.py"
  source = "tfidf_job.py"
}

resource "aws_s3_object" "notebook_file" {
  bucket = aws_s3_bucket.emr_studio_assets.id
  key    = "notebooks/tfidf.ipynb"
  source = "tfidf.ipynb"
}
