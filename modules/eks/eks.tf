# IAM role for EKS cluster
resource "aws_iam_role" "eks" {
  # IAM role name for EKS cluster
  name = "${var.cluster_name}-eks-cluster"

  # Policy that allows EKS service to "assume" this IAM role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}
# Attach IAM role to AmazonEKSClusterPolicy
resource "aws_iam_role_policy_attachment" "eks" {
  # ARN of policy that grants permissions for EKS cluster
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  # IAM role to which the policy is attached
  role = aws_iam_role.eks.name
}

# Create EKS cluster
resource "aws_eks_cluster" "eks" {
  # Cluster name
  name = var.cluster_name
  # ARN of IAM role required for cluster management
  role_arn = aws_iam_role.eks.arn

  # Network configuration (VPC)
  vpc_config {
    endpoint_private_access = true   # Enable private access to API server
    endpoint_public_access = true   # Enable public access to API server
    subnet_ids = var.subnet_ids      # List of subnets where EKS will run
  }

  # EKS cluster access configuration
  access_config {
    authentication_mode = "API"  # Authentication via API
    bootstrap_cluster_creator_admin_permissions = true   # Grant administrative rights to user who created the cluster
  }

  # Dependency on IAM policy for EKS role
  depends_on = [aws_iam_role_policy_attachment.eks]
}
