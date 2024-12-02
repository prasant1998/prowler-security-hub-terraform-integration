## DATA ##

data "aws_region" "current" {} # This is used to get the current region


## IAM ##

resource "aws_iam_role" "taskrole" {
  for_each = toset(var.account_ids)
  name     = "${var.prefix}-assumerole-${each.value}" # This is the role that allows the task role to assume the scan role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.prefix}-prowler-policy" # This is the policy that allows the task role to assume the scan role
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [

        {
          Effect   = "Allow"
          Action   = "sts:AssumeRole"
          Resource = "arn:aws:iam::${each.value}:role/${var.prefix}-scanrole" # This is the role that Prowler will assume to scan the account and send the results to the Security Hub
        }
      ]
    })
  }
}

resource "aws_iam_role" "eventbridgerole" {
  for_each = toset(var.account_ids)
  name     = "${var.prefix}-eventbridge-${each.value}" # This is the role that allows the event bridge to trigger the ECS task
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.prefix}-eventbridge-policy" # This is the policy that allows the event bridge to trigger the ECS task
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "iam:PassRole"
          Resource = [aws_iam_role.taskrole[each.key].arn, aws_iam_role.executionrole.arn]
        },
        {
          Effect   = "Allow"
          Action   = "ecs:RunTask"
          Resource = replace(aws_ecs_task_definition.taskdef[each.key].arn, "/:\\d+$/", ":*")
        }
      ]
    })
  }
}

resource "aws_iam_role" "executionrole" {
  name = "${var.prefix}-executionrole" # This is the role that allows the ECS task to run
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.prefix}-execution-policy" # This is the policy that allows the ECS task to run
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ],
          Resource = [
            "arn:aws:logs:*:*:*"
          ]
        },
      ]
    })
  }
}


## VPC ##



module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "4.0.2"
  name               = "${var.prefix}-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b", "${data.aws_region.current.name}c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = var.use_nat_gateway # We use NAT gateways if true, otherwise we use public IPs
  single_nat_gateway = true
  enable_vpn_gateway = false
}


## ECS ##


resource "aws_ecs_cluster" "cluster" {
  name = "${var.prefix}-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_task_definition" "taskdef" {
  depends_on               = [aws_iam_role.taskrole, aws_iam_role.executionrole]
  for_each                 = toset(var.account_ids)
  family                   = "${var.prefix}-${each.value}"
  task_role_arn            = aws_iam_role.taskrole[each.key].arn
  execution_role_arn       = aws_iam_role.executionrole.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  container_definitions = jsonencode([
    {
      name      = "prowler"
      image     = "toniblyx/prowler:stable"
      cpu       = 2048
      memory    = 4096
      essential = true
      command   = ["-M", "json-asff", "--security-hub", "-R", "arn:aws:iam::${each.value}:role/${var.prefix}-scanrole"] # This is the role that Prowler will assume to scan the account and send the results to the Security Hub
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${var.prefix}-prowler-${each.value}"
          awslogs-region        = data.aws_region.current.name
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "prowler"
        }
      }
    },
  ])
}

module "task_sg" {
  source                                = "terraform-aws-modules/security-group/aws"
  version                               = "5.1.0"
  name                                  = "${var.prefix}-task"
  vpc_id                                = module.vpc.vpc_id
  ingress_with_source_security_group_id = []
  egress_rules                          = ["all-all"]
}



## EVENTBRIDGE ##

resource "aws_cloudwatch_event_rule" "cron" {
  name                = "${var.prefix}-cron"
  description         = "Run the prowler scans periodically"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  for_each  = toset(var.account_ids)
  target_id = "${var.prefix}-${each.value}-scan"
  arn       = aws_ecs_cluster.cluster.arn
  rule      = aws_cloudwatch_event_rule.cron.name
  role_arn  = aws_iam_role.eventbridgerole[each.key].arn
  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.taskdef[each.key].arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = var.use_nat_gateway ? module.vpc.private_subnets : module.vpc.public_subnets
      security_groups  = [module.task_sg.security_group_id]
      assign_public_ip = var.use_nat_gateway ? false : true
    }
  }
}
