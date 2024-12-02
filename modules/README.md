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

If you need more help: [For an extensive write-up check out my blog (this included troubleshooting tips)](https://elasticscale.cloud/en/terraform-module-for-prowler-security-scans/)


## About ElasticScale

ElasticScale is a Solutions Architecture as a Service focusing on start-ups and scale-ups. For a fixed monthly subscription fee, we handle all your AWS workloads. Some services include:

* Migrating **existing workloads** to AWS
* Implementing the **Zero Trust security model**
* Integrating **DevOps principles** within your organization
* Moving to **infrastructure automation** (Terraform)
* Complying with **ISO27001 regulations within AWS**

You can **pause** the subscription at any time and have **direct access** to certified AWS professionals.

Check out our <a href="https://elasticscale.cloud" target="_blank" style="color: #14dcc0; text-decoration: underline">website</a> for more information.

<img src="https://elasticscale-public.s3.eu-west-1.amazonaws.com/logo/Logo_ElasticScale_4kant-transparant.png" alt="ElasticScale logo" width="150"/>

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.0.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_task_sg"></a> [task\_sg](#module\_task\_sg) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 4.0.2 |

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

No outputs.
