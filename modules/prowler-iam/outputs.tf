output "prowler_scanner_role_arn" {
  description = "The ARN of the Prowler scanner role"
  value       = aws_iam_role.prowler_scanner.arn
}

output "prowler_scanner_role_name" {
  description = "The name of the Prowler scanner role"
  value       = aws_iam_role.prowler_scanner.name
}
