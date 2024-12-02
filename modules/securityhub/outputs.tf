output "securityhub_account_id" {
  description = "The ID of the Security Hub enabled account"
  value       = aws_securityhub_account.securityhub.id
}

output "prowler_subscription_arn" {
  description = "The ARN of the Security Hub Prowler product subscription"
  value       = aws_securityhub_product_subscription.prowler_integration.arn
}