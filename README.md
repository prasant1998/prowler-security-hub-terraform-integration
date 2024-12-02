# Terraform Prowler ECS with SecurityHub Integration

This Terraform configuration deploys Prowler security assessment tool on ECS (Elastic Container Service) with AWS SecurityHub integration. The setup enables automated security assessments across multiple AWS accounts with findings reported to SecurityHub.

## Architecture

The solution consists of three main components:
- SecurityHub configuration
- Prowler IAM roles and policies
- Prowler ECS task configuration

## Prerequisites

- Terraform >= 0.13
- AWS CLI configured with appropriate credentials
- Multiple AWS accounts setup (Security account + target accounts)

## Module Structure

```
.
├── main.tf
├── modules/
│ ├── securityhub/
│ ├── prowler-iam/
│ └── prowler-ecs/
└── variables.tf
```

## Command Line Options used for Prowler (Task definition)

- `-M json-asff`: Outputs findings in the AWS Security Hub format.
- `--security-hub`: Enables direct integration with AWS Security Hub.
- `-R`: Specifies the IAM role to assume for scanning.


## Cloudwatch Logs
- Prowler writes logs to Cloudwatch, making it easy to monitor and analyze the security scan results. You can access these logs through the AWS Management Console, AWS CLI, or CloudWatch API. The logs are organized by log groups and streams, allowing you to filter and search for specific events or findings. This centralized logging helps in troubleshooting, auditing, and maintaining a comprehensive record of all security assessments performed by Prowler.

## Usage

1. Configure your variables in a `terraform.tfvars` file:


```hcl
region = "us-east-1"
security_account_id = "123456789012"
account_ids = ["123456789012", "123456789013"]
```


2. Initialize and apply the Terraform configuration:

```bash
terraform init
terraform plan
terraform apply
```


## Modules

### SecurityHub Module
Configures AWS SecurityHub in the specified region.

### Prowler IAM Module
Sets up the necessary IAM roles and policies for Prowler to assess multiple AWS accounts.

### Prowler ECS Module
Deploys Prowler as an ECS task with the following features:
- Runs on a configurable schedule
- Optional NAT Gateway support
- Multi-account assessment capabilities

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| region | AWS region to deploy resources | string | yes |
| security_account_id | AWS account ID where Prowler is deployed | string | yes |
| account_ids | List of AWS account IDs to assess | list(string) | yes |

## Integrating Prowler with AWS Security Hub
To integrate findings into AWS Security Hub, you must use the json-asff format:

```bash
prowler -M json-asff --security-hub
```

## Tools and Services used
- AWS SecurityHub
- Prowler
- AWS ECS with Fargate
- Terraform
- AWS Cloudwatch
- AWS IAM
- AWS EventBridge

## Security Considerations

- Prowler IAM roles use least privilege access
- Cross-account access is strictly controlled
- SecurityHub findings are centralized in the security account