# Home Assignment: "Helm Learning"

## Assignment Description

Create a Kubernetes cluster in the same network (VPC) configured in the previous
homework assignment and implement the following components:

1. Create a Kubernetes cluster using Terraform.

2. Configure Elastic Container Registry (ECR) for storing the Docker image of
   your Django application.

3. Upload the Django Docker image to ECR.

4. Create a Helm chart (`deployment.yaml`, `service.yaml`, `hpa.yaml`,
   `configmap.yaml`).

5. Migrate environment variables (env) from topic 4 to ConfigMap, which will be
   used by your application.

## Project Structure

```
lesson-7/
│
├── main.tf                  # Main file for connecting modules
├── backend.tf               # Backend configuration for state (S3 + DynamoDB)
├── outputs.tf               # Resource outputs
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
│   │   └── outputs.tf       # VPC information output
│   │
│   ├── ecr/                 # Module for ECR
│   │   ├── ecr.tf           # ECR repository creation
│   │   ├── variables.tf     # Variables for ECR
│   │   └── outputs.tf       # ECR repository URL output
│   │
│   └── eks/                 # Module for EKS cluster creation
│       ├── eks.tf           # EKS and Node Groups creation
│       ├── node.tf          # Worker nodes configuration
│       ├── variables.tf     # Module variables
│       └── outputs.tf       # Cluster parameters
│
├── charts/                  # Helm charts
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml    # Deployment for Django application
│       │   ├── service.yaml       # LoadBalancer Service
│       │   ├── configmap.yaml     # Environment variables
│       │   └── hpa.yaml           # Horizontal Pod Autoscaler
│       ├── Chart.yaml             # Chart metadata
│       └── values.yaml            # Configuration values
│
└── README.md                # Project documentation
```

## Assignment Steps

### 1. Create a Kubernetes Cluster

- Using Terraform, create a Kubernetes cluster in the existing network (VPC).
- Provide access to the cluster using `kubectl`.

### 2. Configure ECR

- Using Terraform, create a repository in Amazon Elastic Container Registry
  (ECR).
- Upload the Django Docker image that you created in topic 4 to ECR using AWS
  CLI.

### 3. Create Helm Chart

The Helm chart must implement:

- **Deployment** — with Django image from ECR and ConfigMap connection (via
  `envFrom`).
- **Service** — of type `LoadBalancer` for external access.
- **HPA (Horizontal Pod Autoscaler)** — scaling pods from 2 to 6 when load >
  70%.
- **ConfigMap** — for environment variables (migrated from topic 4).
- **values.yaml** — with image, service, configuration, and autoscaler
  parameters.

## Commands for Initialization, Deployment, and Removal

```bash
# Initialization
terraform init

# Preview infrastructure changes
terraform plan

# Apply infrastructure
terraform apply

# Remove infrastructure
terraform destroy
```

## kubectl Configuration

```bash
# Connect to EKS cluster
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-lesson-7

# Verify access
kubectl get nodes
```

## Docker Image Preparation

```bash
# Navigate to Django project folder
cd docker/django

# Build image without cache
docker build --no-cache -t lesson-7-django-app .

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [ACCOUNT_ID].dkr.ecr.us-east-1.amazonaws.com

# Tag image
docker tag lesson-7-django-app:latest [ACCOUNT_ID].dkr.ecr.us-east-1.amazonaws.com/lesson-7-django-app:latest

# Push to ECR
docker push [ACCOUNT_ID].dkr.ecr.us-east-1.amazonaws.com/lesson-7-django-app:latest
```

**Note**: Replace `[ACCOUNT_ID]` with your AWS account ID. You can get it from
Terraform outputs:

```bash
cd lesson-7
terraform output
```

Or get the ECR repository URL directly:

```bash
terraform output -json | jq -r '.ecr_repository_url.value'
```

## Application Deployment via Helm

```bash
cd lesson-7

# Update values.yaml with your ECR repository URL
# Edit charts/django-app/values.yaml and set the correct image.repository value

# Install Helm chart
helm install django-app ./charts/django-app

# Check status
helm status django-app
kubectl get all
```

## Check LoadBalancer External IP/DNS

```bash
kubectl get service django-app-django
```

Wait for the `EXTERNAL-IP` to be assigned, then access the application:

```bash
curl http://<EXTERNAL-IP>
```

## Remote Backend Configuration

After initial deployment, to activate the remote backend:

1. Uncomment the backend configuration block in `backend.tf`.

2. Run `terraform init` with the parameter to reconnect the backend:

```bash
terraform init -reconfigure
```

## Recovery

If you need to recover from a state issue:

1. Comment out the backend configuration in `backend.tf`.

2. Run `terraform init`.

3. Apply the configuration `terraform apply`.

4. Uncomment the backend and run `terraform init -reconfigure`.

## Prerequisites

Before starting, ensure you have:

- **Terraform** >= 1.0
- **AWS CLI** configured with appropriate credentials
- **kubectl** installed
- **Helm** 3.x installed
- **Docker** installed
- **AWS Account** with necessary permissions:
  - EKS cluster creation
  - EC2, VPC, ECR, S3, DynamoDB resources
  - IAM role and policy management

## Module Descriptions

### S3 Backend Module

Manages Terraform state storage and locking:

- **S3 Bucket**: Stores Terraform state files with versioning enabled
- **DynamoDB Table**: Provides state locking to prevent concurrent modifications

**Variables:**

- `bucket_name`: Name of the S3 bucket
- `table_name`: Name of the DynamoDB table

### VPC Module

Creates networking infrastructure:

- **VPC**: Virtual private cloud with DNS support
- **Public Subnets**: Three subnets across availability zones with internet
  access
- **Private Subnets**: Three subnets for secure resources
- **Internet Gateway**: Provides internet connectivity for public subnets
- **Route Tables**: Configure routing for public subnets

**Variables:**

- `vpc_cidr_block`: CIDR block for the VPC (e.g., "10.0.0.0/16")
- `public_subnets`: List of public subnet CIDR blocks
- `private_subnets`: List of private subnet CIDR blocks
- `availability_zones`: List of availability zones
- `vpc_name`: Name tag for VPC resources

### ECR Module

Creates Docker image registry:

- **ECR Repository**: Container image registry with image scanning
- **Lifecycle Policy**: Automatically cleans up old images (keeps last 10 tagged
  images)

**Variables:**

- `ecr_name`: Name of the ECR repository
- `scan_on_push`: Enable image scanning on push (default: true)

**Outputs:**

- `repository_url`: URL of the ECR repository
- `repository_arn`: ARN of the ECR repository

### EKS Module

Creates Kubernetes cluster:

- **EKS Cluster**: Managed Kubernetes cluster with public and private API
  endpoints
- **IAM Roles**: Cluster and node group IAM roles with required policies
- **Node Group**: Worker nodes with auto-scaling configuration

**Variables:**

- `cluster_name`: Name of the EKS cluster
- `subnet_ids`: List of subnet IDs for the cluster
- `instance_type`: EC2 instance type for worker nodes
- `desired_size`: Desired number of worker nodes
- `min_size`: Minimum number of worker nodes
- `max_size`: Maximum number of worker nodes

**Outputs:**

- `eks_cluster_endpoint`: API endpoint for the cluster
- `eks_cluster_name`: Name of the cluster
- `eks_node_role_arn`: IAM role ARN for worker nodes

## Helm Chart Components

### Deployment

The Django application deployment includes:

- Image from ECR (configurable via `values.yaml`)
- ConfigMap integration via `envFrom`
- Resource limits and requests
- Container port configuration

### Service

LoadBalancer service provides external access to the application:

- Type: `LoadBalancer`
- Port: 80
- Target Port: 8000

### Horizontal Pod Autoscaler (HPA)

Automatically scales pods based on CPU utilization:

- **Min Replicas**: 2
- **Max Replicas**: 6
- **Target CPU**: 70%

HPA can be enabled/disabled via `values.yaml`.

### ConfigMap

Contains environment variables for the Django application:

- Database connection settings (POSTGRES_HOST, POSTGRES_PORT, POSTGRES_USER,
  POSTGRES_DB, POSTGRES_PASSWORD)
- Allowed hosts configuration
- Application-specific settings

All variables are migrated from topic 4 environment configuration.

## Customization

### Update values.yaml

Edit `lesson-7/charts/django-app/values.yaml` to customize:

```yaml
image:
  repository: <your-ecr-repository-url>
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80
  targetPort: 8000

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 6
  targetCPUUtilization: 70

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

config:
  POSTGRES_PORT: "5432"
  POSTGRES_HOST: postgres
  POSTGRES_USER: django_user
  POSTGRES_DB: django_db
  POSTGRES_PASSWORD: <your-password>
```

## Useful Commands

### Terraform

```bash
terraform init          # Initialize Terraform
terraform plan          # Preview changes
terraform apply         # Apply changes
terraform destroy       # Destroy all resources
terraform output        # Show output values
```

### Kubernetes

```bash
kubectl get nodes                    # List cluster nodes
kubectl get pods                     # List pods
kubectl get services                 # List services
kubectl get hpa                      # List HPA resources
kubectl logs <pod-name>              # View pod logs
kubectl describe pod <pod-name>      # Describe pod details
kubectl get configmap                # List ConfigMaps
```

### Helm

```bash
helm list                            # List installed releases
helm status django-app               # Check release status
helm upgrade django-app ./charts/django-app  # Upgrade release
helm uninstall django-app            # Uninstall release
helm template ./charts/django-app    # Render templates
```

### AWS ECR

```bash
aws ecr describe-repositories        # List ECR repositories
aws ecr list-images --repository-name lesson-7-django-app  # List images
aws ecr describe-images --repository-name lesson-7-django-app  # Describe images
```

## Troubleshooting

### EKS Cluster Access Issues

If you cannot access the cluster:

```bash
aws eks update-kubeconfig --region us-east-1 --name eks-cluster-lesson-7
kubectl get nodes
```

### Image Pull Errors

Ensure your ECR repository URL is correct in `values.yaml` and that worker nodes
have the ECR read-only policy attached (automatically configured by the EKS
module).

### Pod Not Starting

Check pod logs:

```bash
kubectl logs <pod-name>
kubectl describe pod <pod-name>
```

### HPA Not Scaling

Verify metrics-server is installed:

```bash
kubectl get deployment metrics-server -n kube-system
```

If not installed:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Cleanup

To destroy all resources:

```bash
# Uninstall Helm release
helm uninstall django-app

# Destroy Terraform resources
cd lesson-7
terraform destroy
```

**Warning**: This will delete all resources including the EKS cluster, ECR
repository, and all application data.

## State Management

This project uses S3 backend with DynamoDB locking:

- State files are stored remotely in S3
- State locking prevents concurrent modifications
- State versioning is enabled in S3
- State encryption is enabled

**Note**: The backend configuration in `backend.tf` is commented out by default.
Uncomment and configure it before initializing if you want to use remote state.

## Additional Notes

- All resources are tagged for identification
- Comments in code are in English
- Follow AWS best practices for resource naming and organization
- Ensure proper IAM permissions for Terraform to create resources
- Worker nodes use lifecycle hooks to ignore changes in `desired_size` to
  prevent conflicts
