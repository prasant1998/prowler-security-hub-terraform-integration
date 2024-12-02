# Terraform Prowler ECS SecurityHub Module

This module deploys Prowler as an ECS task that automatically scans multiple AWS accounts and sends findings to AWS SecurityHub. The scans run on a configurable schedule using EventBridge.

## Description

This module creates an ECS cluster with EventBridge scheduled cron that starts ECS tasks to run Prowler scans on your AWS environments. You provision this module in a security account and specify what accounts you want to scan. 

Steps:

1. Enable Security Hub in every account (without AWS config to save costs) and setup the security account as delegated administrator to centralize the findings
2. Enable the Prowler integration in Security Hub
3. Create IAM roles in the accounts you want to scan with these permissions
    1. arn:aws:iam::aws:policy/SecurityAudit
    2. arn:aws:iam::aws:policy/job-function/ViewOnlyAccess
    3. [The custom policy mentioned here](https://github.com/prowler-cloud/prowler/blob/master/permissions/prowler-additions-policy.json)
    4. [Security hub access](https://github.com/prowler-cloud/prowler/blob/master/permissions/prowler-security-hub.json)
4. Use the following trust policy for the IAM roles

        {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::SECURITYACCOUNTID:role/prowler-scanner-assumerole-SCANACCOUNTID"
                },
                "Action": "sts:AssumeRole"
            }]
        }


## Architecture

The module sets up:
- ECS Fargate cluster with scheduled tasks running Prowler
- VPC with public/private subnets and optional NAT Gateway
- IAM roles for task execution, scanning, and EventBridge scheduling
- CloudWatch Log Groups for Prowler output
- EventBridge rule to schedule regular scans

## Prerequisites

- AWS account with appropriate permissions
- Terraform >= 0.13
- AWS provider configured
- Target accounts must have SecurityHub enabled
- Target accounts must trust the scanning account

## Usage

```hcl
module "prowler_scanner" {
source = "./modules/prowler-ecs"
prefix = "prowler"
account_ids = ["111111111111", "222222222222"]
schedule_expression = "cron(0 0 ? )" # Run daily at midnight
use_nat_gateway = true # Use NAT Gateway instead of public IPs
}
```


## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| prefix | Prefix for all created resources | `string` | n/a | yes |
| account_ids | List of AWS account IDs to scan | `list(string)` | n/a | yes |
| schedule_expression | EventBridge schedule expression | `string` | n/a | yes |
| use_nat_gateway | Whether to use NAT Gateway for outbound traffic | `bool` | n/a | yes |

## Network Configuration

The module creates a VPC with both public and private subnets. You can choose between two networking modes:
- Using NAT Gateway (`use_nat_gateway = true`): Tasks run in private subnets with outbound internet access through NAT
- Using Public IPs (`use_nat_gateway = false`): Tasks run in public subnets with direct internet access

## Security Considerations

- Tasks run with minimal required permissions using dedicated IAM roles
- Network access is restricted to outbound only
- Prowler findings are sent directly to SecurityHub
- All resources are tagged with the provided prefix for easy identification

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.cron](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ecs_scheduled_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_task_definition.taskdef](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.eventbridgerole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.executionrole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.taskrole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | A list of account IDs to scan | `list(string)` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A prefix for the resources | `string` | `"prowler-scanner"` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | The schedule expression for the eventbridge rule (ie how often to run the scans) | `string` | `"cron(0 3 * * ? *)"` | no |
| <a name="input_security_account_id"></a> [security\_account\_id](#input\_security\_account\_id) | The account ID where this module is run from (ie. the security account) | `string` | n/a | yes |
| <a name="input_use_nat_gateway"></a> [use\_nat\_gateway](#input\_use\_nat\_gateway) | We use NAT gateways if true, otherwise we use public IPs | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_arn | The ARN of the ECS cluster |
| cluster_name | The name of the ECS cluster |
| vpc_id | The ID of the VPC |
| private_subnet_ids | List of private subnet IDs |
| public_subnet_ids | List of public subnet IDs |
| task_security_group_id | ID of the security group attached to the Prowler tasks |
| task_role_arns | Map of account IDs to their respective task role ARNs |
| execution_role_arn | ARN of the ECS execution role |
| eventbridge_rule_arn | ARN of the EventBridge rule that triggers the Prowler scans |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.