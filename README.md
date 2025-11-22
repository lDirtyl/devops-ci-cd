# Home Assignment: "Argo CD + CD Learning"

## Prerequisites

Before starting, ensure you have the following tools installed:

### Required Software

1. **Terraform** (>= 1.0)

   ```bash
   # Download from https://www.terraform.io/downloads
   # Or use package manager:
   # Windows (Chocolatey): choco install terraform
   # macOS (Homebrew): brew install terraform
   # Linux: Check your distribution's package manager
   ```

2. **AWS CLI** (v2 recommended)

   ```bash
   # Download from https://aws.amazon.com/cli/
   # Configure with: aws configure
   ```

3. **kubectl**

   ```bash
   # Download from https://kubernetes.io/docs/tasks/tools/
   # Or use package manager
   ```

4. **Helm** (v3.x)

   ```bash
   # Download from https://helm.sh/docs/intro/install/
   # Or use package manager
   ```

5. **Docker**

   ```bash
   # Download from https://www.docker.com/get-started
   ```

6. **Git**
   ```bash
   # Download from https://git-scm.com/downloads
   ```

### AWS Account Requirements

- AWS Account with appropriate permissions:
  - EKS cluster creation
  - EC2, VPC, ECR, S3, DynamoDB resources
  - IAM role and policy management
  - ECR push/pull permissions

### GitHub Requirements

- GitHub account
- Personal Access Token (PAT) with the following permissions:
  - `repo` (full control of private repositories)
  - `workflow` (if using GitHub Actions)

## Assignment Description

Your goal is to implement a complete CI/CD process using Jenkins + Helm +
Terraform + Argo CD, which:

1. Automatically builds a Docker image for the Django application;
2. Publishes the image to Amazon ECR;
3. Updates the Helm chart in the repository with the correct tag;
4. Synchronizes the application in the cluster through Argo CD, which picks up
   changes from Git.

---

## Project Structure

```
├── main.tf                  # Main file for connecting modules
├── backend.tf               # Backend configuration for state (S3 + DynamoDB)
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
│   │   └── outputs.tf       # VPC information output
│   │
│   ├── ecr/                 # Module for ECR
│   │   ├── ecr.tf           # ECR repository creation
│   │   ├── variables.tf     # Variables for ECR
│   │   └── outputs.tf       # ECR repository URL output
│   │
│   ├── eks/                 # Module for EKS cluster creation
│   │   ├── eks.tf           # EKS and Node Groups creation
│   │   ├── variables.tf     # Module variables
│   │   └── outputs.tf       # Cluster parameters
│   │
│   ├── argo_cd/             # Module for Helm installation of Argo CD
│   │   ├── argo_cd.tf       # Helm release for Argo CD
│   │   ├── variables.tf     # Variables (chart version, namespace, repo URL, etc.)
│   │   ├── providers.tf     # Kubernetes+Helm providers
│   │   ├── values.yaml      # Custom Argo CD configuration
│   │   ├── outputs.tf       # Outputs (hostname, initial admin password)
│   │   └── charts/          # Helm chart for creating applications
│   │       ├── Chart.yaml
│   │       ├── values.yaml  # List of applications, repositories
│   │       └── templates/
│   │           ├── application.yaml
│   │           └── repository.yaml
│   │
│   └── jenkins/             # Module for Helm installation of Jenkins
│       ├── jenkins.tf       # Helm release for Jenkins
│       ├── variables.tf     # Variables (resources, credentials, values)
│       ├── values.yaml      # Jenkins configuration
│       └── outputs.tf       # Outputs (URL, administrator password)
│
├── charts/                  # Helm charts
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml    # Deployment for Django application
│       │   ├── service.yaml       # LoadBalancer Service
│       │   ├── configmap.yaml     # Environment variables
│       │   └── hpa.yaml           # Horizontal Pod Autoscaler
│       ├── Chart.yaml             # Chart metadata
│       └── values.yaml            # Configuration values (ConfigMap with environment variables)
│
└── README.md                # Project documentation
```

## Assignment Steps

### 1. Jenkins + Helm + Terraform

- Install Jenkins via Helm, automating the installation through Terraform.
- Ensure Jenkins works through Kubernetes Agent (Kaniko + Git).
- Implement a pipeline (via Jenkinsfile) that:
  - Builds an image from Dockerfile;
  - Pushes it to ECR;
  - Updates the tag in values.yaml of another repository;
  - Pushes changes to main.

### 2. Argo CD + Helm + Terraform

- Install Argo CD via Helm using Terraform.
- Configure Argo CD Application that monitors Helm chart updates.
- Argo CD should automatically synchronize changes in the cluster after Git
  updates.

## Variable Configuration

Create a `terraform.tfvars` file with the following variables:

```
github_token  = <your github token>
github_username  = <your github username>
github_repo_url = "https://github.com/<repo>.git"
```

You can use `terraform.tfvars.example` as a reference.

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
aws eks update-kubeconfig --region us-east-1 --name [EKS_CLUSTER_NAME]

# Verify access
kubectl get nodes
```

## Uploading Docker Image to Newly Created ECR Repository

```bash
# Navigate to Django project folder
cd docker/django

# Build image without cache
docker build --no-cache -t django-app .

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [ACCOUNT_ID].dkr.ecr.us-east-1.amazonaws.com

# Tag image
docker tag django-app:latest [ACCOUNT_ID].dkr.ecr.us-east-1.amazonaws.com/django-app:latest

# Push to ECR
docker push [ACCOUNT_ID].dkr.ecr.us-east-1.amazonaws.com/django-app:latest
```

## Applying Helm Chart

```bash
cd charts/django-app
helm install django-app .
```

where `django-app` is your helm chart name.

## Resource Removal

### Kubernetes (PODs, Services, Deployments, etc.)

```bash
helm uninstall django-app
```

where `django-app` is your helm chart name.

### Terraform (EKS, VPC, ECR, etc.)

```bash
terraform destroy
```

## Additional Information

If you want to update the helm chart:

```bash
helm upgrade django-app .
```

If you want to update terraform:

```bash
terraform init -upgrade
terraform plan
terraform apply
```

### Accessing Jenkins

```bash
# Jenkins URL
kubectl get services -n jenkins

# Get initial Jenkins password
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
```

### Accessing Argo CD

```bash
# Get Argo CD URL
kubectl get services -n argocd

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Remote Backend Configuration

After initial deployment, to activate the remote backend:

1. Uncomment the backend configuration block in `backend.tf`.

2. Run `terraform init` with the parameter to reconnect the backend:

```bash
terraform init -reconfigure
```

### Recovery

1. Comment out the backend configuration in `backend.tf`.

2. Run `terraform init`.

3. Apply the configuration `terraform apply`.

4. Uncomment the backend and run `terraform init -reconfigure`.

## Git Repository Setup

### Initial Git Setup

If you haven't initialized a Git repository yet:

```bash
# Initialize Git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: CI/CD project with Jenkins and Argo CD"
```

### Connect to GitHub

1. **Create a new repository on GitHub:**

   - Go to https://github.com/new
   - Repository name: `devops-ci-cd` (or your preferred name)
   - Choose public or private
   - **Do NOT** initialize with README, .gitignore, or license (if you already
     have files)

2. **Add remote and push:**

   ```bash
   # Add remote repository (replace with your GitHub username)
   git remote add origin https://github.com/YOUR_USERNAME/devops-ci-cd.git

   # Create and switch to lesson-8-9 branch (as used in Jenkinsfile)
   git checkout -b lesson-8-9

   # Push to GitHub
   git push -u origin lesson-8-9
   ```

3. **Update terraform.tfvars:**
   ```hcl
   github_token  = "your_github_personal_access_token"
   github_username  = "your_github_username"
   github_repo_url = "https://github.com/YOUR_USERNAME/devops-ci-cd.git"
   ```

### Creating GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens
   (classic)
2. Click "Generate new token (classic)"
3. Give it a name (e.g., "Jenkins CI/CD")
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (if needed)
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again)
7. Use this token in your `terraform.tfvars` file

### Important Notes

- **Never commit sensitive data:**

  - The `.gitignore` file already excludes:
    - `.env` files
    - `*.tfstate` files
    - `.terraform/` directory
  - **Never commit `terraform.tfvars`** (it contains sensitive tokens)
  - Always use `terraform.tfvars.example` as a template

- **Branch naming:**
  - The Jenkinsfile uses the `lesson-8-9` branch
  - Make sure this branch exists in your repository
  - You can change the branch name in Jenkinsfile if needed

## Project Status

✅ **Project is ready for deployment!**

### What's Included:

- ✅ All Terraform modules (VPC, EKS, ECR, Jenkins, Argo CD)
- ✅ Helm charts for Django application
- ✅ Jenkinsfile for CI/CD pipeline
- ✅ Docker configuration for Django app
- ✅ All comments translated to English
- ✅ Complete documentation in README

### Before First Deployment:

1. ✅ Install all prerequisites (see above)
2. ✅ Configure AWS CLI (`aws configure`)
3. ✅ Create GitHub repository and get Personal Access Token
4. ✅ Create `terraform.tfvars` file with your credentials
5. ✅ Initialize and apply Terraform configuration

### After Deployment:

1. Configure Jenkins credentials in Jenkins UI:

   - Go to Jenkins → Manage Jenkins → Credentials
   - Add credentials with ID `github-token`
   - Type: Username with password
   - Username: Your GitHub username
   - Password: Your GitHub Personal Access Token

2. Create Jenkins pipeline:

   - Create new Pipeline job
   - Point to your repository's Jenkinsfile
   - Configure environment variables:
     - `ECR_REGISTRY`: Your ECR registry URL (from Terraform output)
     - `IMAGE_NAME`: Your ECR repository name (from Terraform output)

3. Access Argo CD:
   - Get Argo CD URL and admin password (see "Accessing Argo CD" section)
   - Argo CD will automatically sync your application from Git
