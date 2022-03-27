provider "aws" {
	region  = var.aws_region
	# default_tags {
	# 	tags = {
	# 		Environment = var.environment_tag
	# 		Owner 		= var.owner_tag
	# 		Project 	= var.project_tag
	# 	}
	# }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.0.0"
    }
  }
}

# terraform {
# 	required_version = ">= 0.12"
#   	backend "s3" {
#     	bucket = data.aws_s3_bucket.project-s3-remotestate.id
#     	key    = "./s3/terraform.tfstate"
#     	region = data.aws_s3_bucket.project-s3-remotestate.region
# 	}
# }

module "vpc" {
	source 						= "./vpc"
	vpc_cidr 					= "10.0.0.0/16"
	number_of_public_subnets 	= 2
	number_of_private_subnets 	= 2
	key_name 					= "opsschool_project_key.pem"
	route53_domain_name			= "opsschool.internal"
}

module "eks" {
  	source 		= "./eks"
	vpc_id 		= module.vpc.vpc_id
	subnets_id 	= "${module.vpc.private_subnets[*]}"
	consul_agents_sg = "${module.vpc.consul_agents_sg}"
	db_username      = var.db_username
	db_password 	 = var.db_password
}

module "jenkins-server" {
	source 				= "./instances/jenkins_server"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"
	vpc_route53_zone	= "${module.vpc.vpc_route53_zone}"

	ec2_instance_security_groups = ["${module.vpc.jenkins_server_sg}", "${module.vpc.consul_agents_sg}"]
	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	bastion_public_ip 			 = "${module.bastion-server.bastion_public_ip[0]}"
}

module "jenkins-agents" {
	source 				= "./instances/jenkins_agents"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 2
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"
	vpc_route53_zone	= "${module.vpc.vpc_route53_zone}"

	ec2_instance_security_groups = ["${module.vpc.consul_agents_sg}"]
	ec2_instance_iam_profile 	 = module.vpc.jenkins-access-eks-profile
	bastion_public_ip 			 = "${module.bastion-server.bastion_public_ip[0]}"

}

module "consul-servers" {
	source 				= "./instances/consul"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 3
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"
	vpc_route53_zone	= "${module.vpc.vpc_route53_zone}"

	ec2_instance_security_groups = ["${module.vpc.consul_servers_sg}", "${module.vpc.consul_agents_sg}"]
	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	bastion_public_ip 			 = "${module.bastion-server.bastion_public_ip[0]}"
}

module "ansible-server" {
	source 				= "./instances/ansible"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"
	vpc_route53_zone	= "${module.vpc.vpc_route53_zone}"

	ec2_instance_security_groups = ["${module.vpc.consul_agents_sg}"]
	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	bastion_public_ip 			 = "${module.bastion-server.bastion_public_ip[0]}"

	depends_on = [
		module.jenkins-server
	]
}

module "prometheus-server" {
	source 				= "./instances/prometheus"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"
	vpc_route53_zone	= "${module.vpc.vpc_route53_zone}"

	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	ec2_instance_security_groups = ["${module.vpc.prometheus_server_sg}", "${module.vpc.consul_agents_sg}"]
	bastion_public_ip 			 = "${module.bastion-server.bastion_public_ip[0]}"
}

module "grafana-server" {
	source 				= "./instances/grafana"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"
	vpc_route53_zone	= "${module.vpc.vpc_route53_zone}"

	ec2_instance_iam_profile 	 = module.vpc.grafana-cloudwatch-profile
	ec2_instance_security_groups = ["${module.vpc.grafana_server_sg}", "${module.vpc.consul_agents_sg}"]
	bastion_public_ip 			 = "${module.bastion-server.bastion_public_ip[0]}"
}

module "elk-server" {
	source 				= "./instances/elk"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"
	vpc_route53_zone	= "${module.vpc.vpc_route53_zone}"

	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	ec2_instance_security_groups = ["${module.vpc.elk_server_sg}", "${module.vpc.consul_agents_sg}"]
	bastion_public_ip 			 = "${module.bastion-server.bastion_public_ip[0]}"
}

module "bastion-server" {
	source 				= "./instances/bastion"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.public_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"
	vpc_route53_zone	= "${module.vpc.vpc_route53_zone}"

	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	ec2_instance_security_groups = ["${module.vpc.bastion_server_sg}", "${module.vpc.consul_agents_sg}"]
}

module "db-server" {
	source 				= "./instances/db"
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	vpc_route53_zone	= "${module.vpc.vpc_route53_zone}"
	db_username   		= var.db_username
	db_password 		= var.db_password

	db_instance_security_groups = ["${module.vpc.db_server_sg}", "${module.vpc.consul_agents_sg}"]
}

module "alb" {
	source 							= "./loadbalancer"
	vpc_id 							= module.vpc.vpc_id
	subnets_id 						= "${module.vpc.public_subnets[*]}"
	vpc_route53_zone				= "${module.vpc.vpc_route53_zone}"

	ec2_instance_security_groups 	= ["${module.vpc.consul_servers_sg}","${module.vpc.jenkins_server_sg}", "${module.vpc.prometheus_server_sg}", "${module.vpc.grafana_server_sg}", "${module.vpc.elk_server_sg}"]
	consul_servers_target_group 	= module.consul-servers.instance_id
	jenkins_server_target_group 	= module.jenkins-server.instance_id
	prometheus_server_target_group	= module.prometheus-server.instance_id
	grafana_server_target_group		= module.grafana-server.instance_id
	elk_server_target_group 		= module.elk-server.instance_id 
}