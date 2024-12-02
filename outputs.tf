## Prowler ECS

output "cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.cluster.arn
}

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.cluster.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}





## Prowler IAM


output "prowler_scanner_role_name" {
  description = "The name of the Prowler scanner role"
  value       = aws_iam_role.prowler_scanner.name
}

## Security Hub

output "securityhub_account_id" {
  description = "The ID of the Security Hub enabled account"
  value       = aws_securityhub_account.securityhub.id
}
