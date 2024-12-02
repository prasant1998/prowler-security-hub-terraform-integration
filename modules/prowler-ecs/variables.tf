variable "security_account_id" {
  description = "The account ID where this module is run from (ie. the security account)"
  type        = string
}
variable "account_ids" {
  description = "A list of account IDs to scan"
  type        = list(string)
}
variable "prefix" {
  description = "A prefix for the resources"
  type        = string
  default     = "prowler-scanner"
}
variable "use_nat_gateway" {
  description = "We use NAT gateways if true, otherwise we use public IPs"
  type        = bool
  default     = false
}
variable "schedule_expression" {
  description = "The schedule expression for the eventbridge rule (ie how often to run the scans)"
  type        = string
  default     = "cron(0 3 * * ? *)"
}
