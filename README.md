# Terraform AWS Infrastructure Project

This project creates a modular AWS infrastructure using Terraform, including S3
backend for state management, VPC networking, and ECR for container images.

## Project Structure

```
devops-ci-cd/
├── lesson-5/
│   ├── backend.tf          # Terraform backend configuration (S3 + DynamoDB)
│   ├── main.tf             # Main configuration file with module declarations
│   ├── outputs.tf          # Output values from modules
│   └── modules/
│       ├── s3-backend/     # S3 bucket and DynamoDB table for state management
│       │   ├── s3.tf
│       │   ├── dynamodb.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── vpc/            # VPC networking module
│       │   ├── vpc.tf      # VPC, subnets, and Internet Gateway
│       │   ├── routes.tf   # Route tables and associations
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── ecr/            # Elastic Container Registry module
│           ├── ecr.tf
│           ├── variables.tf
│           └── outputs.tf
└── README.md
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions
- Default AWS profile configured (or update the provider configuration)

## Terraform Commands

### Initialize Terraform

Initialize the Terraform working directory and download required providers:

```bash
cd lesson-5
terraform init
```

This command will:

- Download the AWS provider plugin
- Configure the S3 backend for state storage
- Initialize all modules

### Plan Infrastructure Changes

Preview the infrastructure changes before applying them:

```bash
terraform plan
```

This command shows:

- Resources that will be created
- Resources that will be modified
- Resources that will be destroyed
- Any configuration issues

### Apply Infrastructure Changes

Create or update the infrastructure according to the configuration:

```bash
terraform apply
```

Terraform will:

- Prompt for confirmation (use `-auto-approve` to skip)
- Create/modify resources in the correct order
- Store the state in the S3 backend

### Destroy Infrastructure

Remove all resources created by this configuration:

```bash
terraform destroy
```

**Warning:** This will delete all resources. Use with caution.

## Modules Description

### s3-backend Module

This module creates the backend infrastructure for Terraform state management.

**Resources:**

- **S3 Bucket**: Stores Terraform state files with versioning enabled
- **DynamoDB Table**: Provides state locking to prevent concurrent modifications

**Features:**

- Versioning enabled on the S3 bucket
- Ownership controls configured
- Pay-per-request billing mode for DynamoDB
- Encryption enabled for state files

**Variables:**

- `bucket_name`: Name of the S3 bucket for Terraform states
- `table_name`: Name of the DynamoDB table for state locking

**Outputs:**

- `s3_bucket_name`: Name of the created S3 bucket
- `dynamodb_table_name`: Name of the DynamoDB locking table

### vpc Module

This module creates a complete VPC networking setup with public and private
subnets.

**Resources:**

- **VPC**: Main virtual private cloud with DNS support
- **Public Subnets**: Three subnets (one per availability zone) with internet
  access
- **Private Subnets**: Three subnets (one per availability zone) without direct
  internet access
- **Internet Gateway**: Provides internet connectivity for public subnets
- **Route Tables**: Separate routing for public subnets
- **Route Table Associations**: Links subnets to route tables

**Features:**

- Multi-AZ deployment across three availability zones
- Public subnets with auto-assign public IP
- Private subnets for secure resources
- Proper route table configuration for internet access

**Variables:**

- `vpc_cidr_block`: CIDR block for the VPC (e.g., "10.0.0.0/16")
- `public_subnets`: List of CIDR blocks for public subnets
- `private_subnets`: List of CIDR blocks for private subnets
- `availability_zones`: List of availability zones for subnets
- `vpc_name`: Name tag for the VPC and resources

**Outputs:**

- `vpc_id`: ID of the created VPC
- `public_subnets`: List of public subnet IDs
- `private_subnets`: List of private subnet IDs
- `internet_gateway_id`: ID of the Internet Gateway

### ecr Module

This module creates an Elastic Container Registry (ECR) repository for Docker
images.

**Resources:**

- **ECR Repository**: Container image registry
- **Lifecycle Policy**: Automatic cleanup of old images (keeps last 10 tagged
  images)

**Features:**

- Image scanning on push (configurable)
- Mutable image tags
- Automatic lifecycle management
- Tagged resources for easy identification

**Variables:**

- `ecr_name`: Name of the ECR repository
- `scan_on_push`: Enable image scanning on push (default: true)

**Outputs:**

- `repository_url`: URL of the ECR repository
- `repository_arn`: ARN of the ECR repository
- `registry_id`: Registry ID of the ECR repository

## Configuration

### Current Settings

- **AWS Region**: us-east-1
- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
- **Private Subnets**: 10.0.4.0/24, 10.0.5.0/24, 10.0.6.0/24
- **Availability Zones**: us-east-1a, us-east-1b, us-east-1c
- **S3 Bucket**: andrii_mashtaler-terraform-state-bucket-001001
- **DynamoDB Table**: terraform-locks

### Customization

To customize the infrastructure, modify the values in `lesson-5/main.tf`:

- Change VPC CIDR blocks
- Adjust subnet configurations
- Modify ECR repository name
- Update S3 bucket and DynamoDB table names

## State Management

This project uses an S3 backend with DynamoDB locking:

- State files are stored remotely in S3
- State locking prevents concurrent modifications
- State versioning is enabled in S3
- State encryption is enabled

**Note:** The S3 bucket and DynamoDB table must be created before initializing
the backend, or the backend configuration should be commented out initially.

## Outputs

After applying the configuration, you can view outputs:

```bash
terraform output
```

Available outputs:

- `s3_bucket_name`: S3 bucket name for Terraform states
- `dynamodb_table_name`: DynamoDB table name for state locking

## Additional Information

- All resources are tagged for identification
- Comments in code are in English
- Follow AWS best practices for resource naming and organization
- Ensure proper IAM permissions for Terraform to create resources
