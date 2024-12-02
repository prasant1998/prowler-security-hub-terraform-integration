# AWS Security Hub Terraform Module

This Terraform module enables AWS Security Hub and configures integration with Prowler security assessment tool.

## Description

This module:
- Enables AWS Security Hub in your AWS account with default standards disabled
- Configures Security Hub to accept findings from Prowler security scanner

## Requirements

- Terraform >= 0.12
- AWS Provider
- AWS Account with appropriate permissions to enable Security Hub

## Usage

```hcl
module "securityhub" {
  source = "./modules/securityhub"
  region = "ap-northeast-2"
}
```



## Resources

| Name | Type | Description |
|------|------|-------------|
| [aws_securityhub_account.securityhub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | Resource | Enables Security Hub for the AWS Account |
| [aws_securityhub_product_subscription.prowler_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_product_subscription) | Resource | Enables integration with Prowler security scanner |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | AWS region where Security Hub will be enabled | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| securityhub_account_id | The ID of the Security Hub enabled account |
| prowler_subscription_arn | The ARN of the Security Hub Prowler product subscription |

## Important Notes

- Default security standards are disabled by default (`enable_default_standards = false`). Enable them if needed by modifying the configuration.
- This module assumes Prowler is or will be configured separately to send findings to Security Hub.
- Make sure your AWS credentials have sufficient permissions to manage Security Hub resources.

## Related Documentation

- [AWS Security Hub Documentation](https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html)
- [Prowler Documentation](https://github.com/prowler-cloud/prowler)
