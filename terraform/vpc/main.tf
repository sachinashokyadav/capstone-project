###########################################
# Providers
###########################################
provider "aws" {
  region = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

###########################################
# Locals
###########################################
locals {
  cluster_name = var.cluster_name
}

###########################################
# Step 1: Get EKS Cluster Details & OIDC
###########################################
data "aws_eks_cluster" "eks" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = local.cluster_name
}

data "tls_certificate" "oidc_cert" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# Import or reference existing OIDC provider if already created manually
resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_cert.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

###########################################
# Step 2: AWS Load Balancer Controller Policy
###########################################
resource "aws_iam_policy" "alb_controller_policy" {
  name        = "${local.cluster_name}-alb-controller-policy"
  description = "AWS Load Balancer Controller IAM policy"
  policy      = file("${path.module}/iam_policy_alb_controller.json")
}

###########################################
# Step 3: IAM Role for Service Account (IRSA)
###########################################
resource "aws_iam_role" "alb_controller_role" {
  name = "${local.cluster_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:capstone:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

###########################################
# Step 4: Use Existing Namespace and Create Service Account
###########################################
data "kubernetes_namespace" "capstone" {
  metadata {
    name = "capstone"
  }
}
resource "kubernetes_service_account" "alb_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = data.kubernetes_namespace.capstone.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role.arn
    }
  }
}

###########################################
# Step 5: Deploy AWS Load Balancer Controller via Helm
###########################################
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = data.kubernetes_namespace.capstone.metadata[0].name

  create_namespace = false

  set = [
    {
      name  = "clusterName"
      value = data.aws_eks_cluster.eks.name
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.alb_sa.metadata[0].name
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    }
  ]

  timeout = 600
depends_on = [
    aws_iam_role.alb_controller_role,
    aws_iam_role_policy_attachment.alb_attach,
    kubernetes_service_account.alb_sa
  ]
}
