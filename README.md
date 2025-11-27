# Homework: Creating a Flexible Terraform Module for Databases

## Task Description

Implement a universal `rds` module that:

1. Deploys Aurora Cluster or standard RDS instance based on the `use_aurora`
   value;
2. Automatically creates:
   - **DB Subnet Group**
   - **Security Group**
   - **Parameter Group** for the selected database type
3. Works with minimal variable changes and supports reusable usage.

---

## Project Structure

```
├── main.tf                  # Main file for connecting modules
├── backend.tf               # Backend configuration for states (S3 + DynamoDB)
├── outputs.tf               # General resource outputs
│
├── modules/                 # Directory with all modules
│   │
│   ├── s3-backend/          # Module for S3 and DynamoDB
│   │   ├── s3.tf            # S3 bucket creation
│   │   ├── dynamodb.tf      # DynamoDB creation
│   │   ├── variables.tf     # Variables for S3
│   │   └── outputs.tf       # Output information about S3 and DynamoDB
│   │
│   ├── vpc/                 # Module for VPC
│   │   ├── vpc.tf           # VPC, subnets, Internet Gateway creation
│   │   ├── routes.tf        # Routing configuration
│   │   ├── variables.tf     # Variables for VPC
│   │   └── outputs.tf       # VPC output information
│   │
│   ├── ecr/                 # Module for ECR
│   │   ├── ecr.tf           # ECR repository creation
│   │   ├── variables.tf     # Variables for ECR
│   │   └── outputs.tf        # ECR repository URL output
│   │
│   ├── eks/                 # Module for EKS cluster creation
│   │   ├── eks.tf           # EKS and Node Groups creation
│   │   ├── variables.tf     # Module variables
│   │   └── outputs.tf       # Cluster parameters
│   │
│   ├── rds/                 # Module for RDS
│   │   ├── rds.tf           # RDS database creation
│   │   ├── aurora.tf        # Aurora cluster database creation
│   │   ├── shared.tf        # Shared resources
│   │   ├── variables.tf     # Variables (resources, credentials, values)
│   │   └── outputs.tf
│   │
│   ├── jenkins/             # Module for Helm installation of Jenkins
│   │   ├── jenkins.tf       # Helm release for Jenkins
│   │   ├── variables.tf     # Variables (resources, credentials, values)
│   │   ├── values.yaml      # Jenkins configuration
│   │   └── outputs.tf       # Outputs (URL, administrator password)
│   │
│   └── argo_cd/             # Module for Helm installation of Argo CD
│      ├── jenkins.tf       # Helm release for Jenkins
│      ├── variables.tf     # Variables (chart version, namespace, repo URL, etc.)
│      ├── providers.tf     # Kubernetes+Helm. moved from jenkins module
│      ├── values.yaml      # Custom Argo CD configuration
│      ├── outputs.tf       # Outputs (hostname, initial admin password)
│      └──charts/                  # Helm chart for creating apps
│         ├── Chart.yaml
│         ├── values.yaml          # List of applications, repositories
│         └── templates/
│             ├── application.yaml
│             └── repository.yaml
│
├── charts/                        # Helm charts
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml    # Deployment for Django application
│       │   ├── service.yaml       # LoadBalancer Service
│       │   ├── configmap.yaml    # Environment variables
│       │   └── hpa.yaml           # Horizontal Pod Autoscaler
│       ├── Chart.yaml             # Chart metadata
│       └── values.yaml            # Configuration values (ConfigMap with environment variables)
│
└── README.md                # Project documentation
```

## Module Functionality:

- `use_aurora` = `true` → creates Aurora Cluster + writer;
- `use_aurora` = `false` → creates a single `aws_db_instance`;
- In both cases:
  - creates `aws_db_subnet_group`;
  - creates `aws_security_group`;
  - creates `parameter group` with basic parameters (`max_connections`,
    `log_statement`, `work_mem`);
  - Parameters `engine`, `engine_version`, `instance_class`, `multi_az` are set
    via variables.

## Variable Configuration

Create a `terraform.tfvars` file in the project root with the following
variables:

```
github_token = <github_token>
github_username = <github_username>
github_repo_url = "https://github.com/<repo>.git"

rds_password = <rds_password>
rds_username = <rds_username>
rds_database_name = <rds_database_name>
rds_publicly_accessible = true

# true → creates Aurora Cluster + writer
# false → creates a single aws_db_instance
rds_use_aurora = true

rds_multi_az = false
rds_backup_retention_period = "0"
```

You can also use `terraform.tfvars.example` as an example.

## Environment Setup

`region` defaults to `us-east-1`

```
terraform init
terraform plan
terraform apply
```

## kubectl Configuration

```bash
# Connect to EKS cluster
aws eks update-kubeconfig --region us-east-1 --name <your_cluster_name>

# Check access
kubectl get nodes

# or check services in the cluster:
kubectl get svc -A
```

## Resource Removal

```bash
terraform destroy
```

## Remote Backend Configuration

After initial deployment to activate the remote backend:

1. Uncomment the backend configuration block in `backend.tf`.

2. Run the `terraform init` command with the parameter to reconnect the backend:

```bash
terraform init -reconfigure
```

## Recovery

1. Comment out the backend configuration in `backend.tf`.
2. Run `terraform init`.
3. Apply the configuration `terraform apply`.
4. Uncomment the backend and run `terraform init -reconfigure`.
