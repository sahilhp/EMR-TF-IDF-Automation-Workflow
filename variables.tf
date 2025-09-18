variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "notification_email" {
  description = "The email address to send billing alerts to. You must confirm the subscription."
  type        = string
}

variable "billing_alert_threshold" {
  description = "The monthly cost in USD that will trigger a billing alert."
  type        = number
  default     = 10 # Default to $10
}
