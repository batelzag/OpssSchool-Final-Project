# The Bation server public ip address
output "bastion_public_ip" {
  description = "The Bastion server public ip address"
  value       = module.bastion-server.bastion_public_ip
}

# The ALB DNS name
output "alb_dns_name" {
  description = "The ALB DNS name in order to access the UI of Jenkins & Consul & grafana & prometheus"
  value       = module.alb.alb_dns_name
}

# Consul URL
output "consul_url" {
  description = "The URL to access the UI of Consul"
  value       = "http://${module.alb.alb_dns_name}:8500"
}

# Jenkins Server URL
output "jenkins_url" {
  description = "The URL to access the UI of Jenkins"
  value       = "http://${module.alb.alb_dns_name}:8080"
}

# Prometheus Server URL
output "prometheus_url" {
  description = "The URL to access the UI of prometheus"
  value       = "http://${module.alb.alb_dns_name}:9090"
}

# Grafana Server URL
output "grafana_url" {
  description = "The URL to access the UI of Grafana"
  value       = "http://${module.alb.alb_dns_name}:3000"
}

# Kibana Server URL
output "kibana_url" {
  description = "The URL to access the UI of Grafana"
  value       = "http://${module.alb.alb_dns_name}:5601"
}

# The EKS cluster name
output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

# The ARN of the Jenkins eks access role
output "jenkins_eks_role_arn" {
  description = "Jenkins eks access role arn"
  value       = module.vpc.jenkins_eks_role
}