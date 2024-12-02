# Prowler IAM Module

This Terraform module creates the necessary IAM roles and policies for running Prowler security assessments in AWS with SecurityHub integration.

## Overview

This module sets up IAM roles and policies that allow Prowler to:
- Perform security assessments across your AWS account
- Send findings to AWS SecurityHub
- Access necessary AWS services with least-privilege permissions

## Resources Created

- `prowler` IAM role with assume role trust policy
- Custom IAM policies:
  - SecurityHub integration policy
  - Prowler-specific permissions policy
- Attachments of AWS managed policies:
  - `ViewOnlyAccess`
  - `SecurityAudit`

## Usage

```hcl
module "prowler_iam" {
  source = "./modules/prowler-iam"
  security_account_id = "585853585762"
  account_ids = ["111111111111", "222222222222"]
}
```



## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0.0 |

## Resources

| Name | Type |
|------|------|
| aws_iam_role.prowler | resource |
| aws_iam_role_policy.prowler_securityhub_policy | resource |
| aws_iam_role_policy.prowler_custom_policy | resource |
| aws_iam_role_policy_attachment.prowler_job_function_attach_policy | resource |
| aws_iam_role_policy_attachment.prowler_security_attach_policy | resource |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| security_account_id | AWS Account ID where the Prowler scanner is running | `string` | yes |
| account_ids | List of AWS account IDs to be scanned by Prowler | `list(string)` | yes |

## Outputs

| Name | Description |
|------|-------------|
| prowler_role_arn | ARN of the created Prowler IAM role |
| prowler_role_name | Name of the created Prowler IAM role |

## Permissions

The module creates roles with the following access:
- Read-only access to multiple AWS services for security assessment
- Ability to import and update findings in SecurityHub
- Custom permissions for specific API calls required by Prowler

### SecurityHub Permissions
- securityhub:BatchImportFindings
- securityhub:BatchUpdateFindings
- securityhub:GetFindings

### AWS Managed Policies
- ViewOnlyAccess
- SecurityAudit

### Custom Policy Permissions
The module includes a comprehensive set of read-only permissions for various AWS services including:
- Account Management
- AppStream
- Backup
- CloudTrail
- CodeArtifact
- EC2
- Lambda
- And many more (see prowler_custom_policy in the code for full list)

## Notes

- The commented-out sections at the top of the module contain an optional scanner assume role configuration
- The module follows AWS security best practices by implementing least-privilege access
- Additional permissions can be added to the custom policy as needed for new Prowler checks

## Related Documentation

- [Prowler Documentation](https://github.com/prowler-cloud/prowler)
- [AWS SecurityHub Documentation](https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html)
