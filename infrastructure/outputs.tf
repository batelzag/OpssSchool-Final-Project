# The Bation server public ip address
output "bastion_public_ip" {
  description = "The Bastion server public ip address"
  value       = module.bastion-server.bastion_public_ip
}

# The ALB DNS name
output "alb_dns_name" {
  description = "The ALB DNS name in order to access the UI of Jenkins & Consul"
  value       = module.alb.alb_dns_name
}

# The EKS cluster name
# output "cluster_name" {
#   description = "Kubernetes Cluster Name"
#   value       = module.elk.cluster_name
# }

# maybe add also the eks endpoint