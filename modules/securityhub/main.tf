# Enable Security Hub

resource "aws_securityhub_account" "securityhub" {
  enable_default_standards = false
}

# Accept findings from Prowler by creating a product subscription
resource "aws_securityhub_product_subscription" "prowler_integration" {
  product_arn = "arn:aws:securityhub:${var.region}::product/prowler/prowler"
  depends_on = [aws_securityhub_account.securityhub]
}
