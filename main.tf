data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    testing_nodes = {
      name           = "testing-nodes"
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      instance_types = ["t3a.medium", "t3.medium"]
      capacity_type  = "SPOT"
      subnet_ids     = module.vpc.private_subnets
    }
  }

  enable_cluster_creator_admin_permissions = true
}

resource "helm_release" "test_namespace_baseline" {
  name             = "test-namespace-baseline"
  chart            = "${path.module}/charts/namespace-baseline"
  namespace        = "workload-test"
  create_namespace = true
  wait             = false
  values = [
    file("${path.module}/charts/namespace-baseline/values.yaml")
  ]
  depends_on = [module.eks]
}
