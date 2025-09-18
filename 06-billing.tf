# 1. Create an SNS topic to send alerts to
resource "aws_sns_topic" "billing_alerts" {
  name = "billing-alerts-topic"
}

# 2. Subscribe your email address to the SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# 3. Create the CloudWatch alarm that monitors estimated charges
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "aws-monthly-billing-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600" # 6 hours
  statistic           = "Maximum"
  threshold           = var.billing_alert_threshold
  alarm_description   = "This alarm triggers when monthly AWS charges exceed the threshold."
  
  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.billing_alerts.arn]
  ok_actions    = [aws_sns_topic.billing_alerts.arn]
}
