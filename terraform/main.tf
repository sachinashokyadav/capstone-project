module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 3.0"
  name = var.project
  cidr = var.vpc_cidr
  azs  = ["${var.region}a","${var.region}b"]
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  enable_nat_gateway = true
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = ">= 20.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    ng-ondemand = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
    ng-spot = {
      desired_capacity = 0
      max_capacity     = 3
      min_capacity     = 0
      instance_type    = "t3.medium"
      capacity_type    = "SPOT"
    }
  }

  manage_aws_auth = true
}

resource "aws_ecr_repository" "frontend" {
  name = "${var.project}-frontend"
}
resource "aws_ecr_repository" "backend" {
  name = "${var.project}-backend"
}
resource "aws_ecr_repository" "mongodb" {
  name = "${var.project}-mongodb"
}

