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

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "task_security_group_id" {
  description = "ID of the security group attached to the Prowler tasks"
  value       = module.task_sg.security_group_id
}

output "task_role_arns" {
  description = "Map of account IDs to their respective task role ARNs"
  value       = { for k, v in aws_iam_role.taskrole : k => v.arn }
}

output "execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = aws_iam_role.executionrole.arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule that triggers the Prowler scans"
  value       = aws_cloudwatch_event_rule.cron.arn
}