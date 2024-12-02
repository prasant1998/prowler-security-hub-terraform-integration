## SECURITY HUB ##

module "securityhub" {
  source = "./modules/securityhub"
  region = var.region
}

## PROWLER IAM ##

module "prowler_iam" {
  source = "./modules/prowler-iam"
  security_account_id = var.security_account_id
  account_ids = var.account_ids
}



## PROWLER ##

module "prowler" {
  source  = "./modules/prowler-ecs"
  account_ids = var.account_ids
  security_account_id = var.security_account_id
  use_nat_gateway = false
  # schedule_expression = "cron(*/5 * * * ? *)"
}