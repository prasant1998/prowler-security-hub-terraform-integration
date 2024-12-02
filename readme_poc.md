# Integrating Prowler with AWS Security Hub for Comprehensive Security Audits

The current POC is to integrate Prowler with SecurityHub using ECS.


## Statements
- Prowler is a security tool that scans your AWS environment and reports findings.
- SecurityHub is a centralized security service that collects, aggregates, and prioritizes findings from multiple AWS services and tools.
- ECS is a managed container orchestration service that allows you to deploy, scale, and manage containerized applications.

## Prowler

Prowler scans across many AWS services to help ensure that security best practices are followed. This includes auditing IAM configurations, networking security, storage security (S3), compliance with logging standards (CloudTrail/CloudWatch), and encryption standards across services like EC2, RDS, Lambda, and more.

## Why ECS for Prowler?

### ECS vs EC2

#### ECS Advantages
- **Container Management**: ECS handles container orchestration, scaling, and management automatically
- **Resource Efficiency**: Only uses resources when tasks are running
- **No Server Management**: No need to manage EC2 instances, patching, or OS updates
- **Cost Effective**: Pay only for the container runtime, not for idle EC2 instances
- **Security**: Reduced attack surface as containers are ephemeral
- **Isolation**: Each Prowler run is isolated in its own container

#### EC2 Disadvantages
- Requires server management and maintenance
- Always running (unless using ASG with scheduled scaling)
- Need to handle OS updates and security patches
- Higher costs for 24/7 running instances
- Manual container orchestration if using containers

### ECS vs Lambda

#### Lambda Limitations for Prowler
- **15-minute timeout**: Prowler scans often take longer than Lambda's maximum execution time
- **Memory constraints**: Lambda has a 10GB memory limit
- **Complex deployment**: Would require breaking Prowler into multiple functions

#### ECS Benefits for Prowler
- **No time limits**: Can run full scans without timeout constraints
- **Flexible resources**: Can allocate CPU and memory as needed
- **Single deployment**: Entire Prowler scan runs as one task

### Best Use Cases

1. **Use ECS when**:
   - Running full compliance scans
   - Need consistent and predictable performance
   - Want automated container management
   - Require longer running tasks

2. **Use EC2 when**:
   - Need full control over the host system
   - Have specific OS or kernel requirements
   - Want to run Prowler alongside other tools

3. **Use Lambda when**:
   - Running quick, specific checks
   - Need serverless event-driven scanning
   - Scans complete within 15 minutes
   - Running individual Prowler modules

## Cloudwatch Logs
- Prowler writes logs to Cloudwatch.
- SecurityHub expects the logs to be in ASFF format.

## Challenges
- Prowler is not designed to be run as a cron job. It is designed to be run on-demand.  
- Prowler outputs are in json and yaml format. SecurityHub expects ASFF format.

## Docker Image
- https://hub.docker.com/r/prowlercloud/prowler


## Blog
- https://securing-aws-infrastructure.hashnode.dev/securing-aws-infrastructure-prowler-and-security-hub-integration-with-terraform


## References
- https://docs.prowler.com/projects/prowler-open-source/en/latest/tutorials/aws/securityhub/#send-findings
- https://elasticscale.com/blog/terraform-module-for-prowler-security-scans/
- https://github.com/prowler-cloud/prowler/blob/master/permissions/prowler-additions-policy.json
- https://github.com/prowler-cloud/prowler/blob/master/permissions/prowler-security-hub.json
- https://registry.terraform.io/modules/elasticscale/prowler/aws/latest?tab=resources
