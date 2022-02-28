# Kubernetes minor version to use for the EKS cluster
variable "kubernetes_version" {
  default     = 1.21
  description = "kubernetes version"
}

resource "random_string" "suffix" {
  length      = 8
  special     = false
}

locals {
  cluster_name = "project-eks-${random_string.suffix.result}"
}

locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "project-sa"
}

#  VPC where the cluster and workers will be deployed
variable  "vpc_id" {
  type = string
}

# The subnets ids to place the EKS cluster and workers within
variable "subnets_id" {
  type = list(string)
}