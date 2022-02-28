module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  vpc_id          = var.vpc_id
  subnets         = var.subnets_id

  enable_irsa = true
  
  tags = {
    Environment = "mid-project"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  worker_groups = [
    {
      name                          = "project-worker-group-1"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    },
    {
      name                          = "project-worker-group-2"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    }
  ]

}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}
