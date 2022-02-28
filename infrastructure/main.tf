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

# terraform {
# 	required_version = ">= 0.12"
#   	backend "s3" {
#     	bucket = "terraformstate-environments/Development/"
#     	key    = "./terraform.tfstate"
#     	region = "us-east-1"
# 	}
# }

module "vpc" {
	source 						= "./vpc"
	vpc_cidr 					= "10.0.0.0/16"
	number_of_public_subnets 	= 2
	number_of_private_subnets 	= 2
	key_name 					= "mid_project_key.pem"
}

# module "eks" {
#   	source 		= "./eks"
# 	vpc_id 		= module.vpc.vpc_id
# 	# key_name 	= "${module.vpc.pem_key_name}"
# 	subnets_id 	= "${module.vpc.public_subnets[*]}" #change to private
# }

module "jenkins-server" {
	source 				= "./instances/consul_and_jenkins"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"

	ec2_instance_security_groups = ["${module.vpc.jenkins_server_sg}", "${module.vpc.consul_agents_sg}"]
	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	# configuration_script 		 = "../configuration/scripts/jenkins_server.sh" #change to "./configuration/scripts/jenkins_server.sh"
	user_data_script 			 = "${data.template_cloudinit_config.jenkins_server.rendered}"

	# consul_node_name = "jenkins-server"
	
	additional_tags = {
		Name			= "jenkins-server"
    	consul_server 	= "false"
	}
}

module "jenkins-agents" {
	source 				= "./instances/consul_and_jenkins"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 2
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"

	ec2_instance_security_groups = ["${module.vpc.consul_agents_sg}"]
	ec2_instance_iam_profile 	 = module.vpc.jenkins-access-eks-profile
	# configuration_script 		 = "../configuration/scripts/jenkins_agent.sh" #change to "./configuration/scripts/jenkins_agent.sh"
	user_data_script 			 = "${data.template_cloudinit_config.jenkins_agent.rendered}"


	# consul_node_name = "jenkins-agent"
	
	additional_tags = {
		Name 			= "jenkins-agent"
    	consul_server 	= "false"
	}
}

module "consul-servers" {
	source 				= "./instances/consul_and_jenkins"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 3
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"

	ec2_instance_security_groups = ["${module.vpc.consul_servers_sg}", "${module.vpc.consul_agents_sg}"]
	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	# configuration_script 		 = "../configuration/scripts/consul_server.sh" #change to "./configuration/scripts/consul_server.sh"
	user_data_script 			 = "${data.template_cloudinit_config.consul_server.rendered}"


	# consul_node_name = "consul-server"
	
	additional_tags = {
		Name 			= "consul-server"
    	consul_server 	= "true"
	}
}

module "ansible-server" {
	source 				= "./instances/ansible"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"

	ec2_instance_security_groups = ["${module.vpc.consul_agents_sg}"]
	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	bastion_public_ip 			 = "${module.bastion-server.bastion_public_ip[0]}"
	# configuration_script 		 = "../configuration/scripts/ansible_server.sh"
	user_data_script 			 = "${data.template_cloudinit_config.ansible_server.rendered}"


	# consul_node_name = "ansible-server"

	additional_tags = {
		Name 			= "ansible-server"
    	consul_server 	= "false"
	}

	depends_on = [
		module.jenkins-server
	]
}

module "prometheus-server" {
	source 				= "./instances/consul_and_jenkins"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"

	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	ec2_instance_security_groups = ["${module.vpc.prometheus_server_sg}", "${module.vpc.consul_agents_sg}"]
	user_data_script 			 = "${data.template_cloudinit_config.prometheus_server.rendered}"

	# consul_node_name = "prometheus-server"

	additional_tags = {
		Name = "prometheus-server"
		consul_server 	= "false"
	}
}

module "grafana-server" {
	source 				= "./instances/consul_and_jenkins"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.private_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"

	ec2_instance_iam_profile 	 = module.vpc.consul-join-profile
	ec2_instance_security_groups = ["${module.vpc.grafana_server_sg}", "${module.vpc.consul_agents_sg}"]
	user_data_script 			 = "${data.template_cloudinit_config.grafana_server.rendered}"

	# consul_node_name = "grafana-server"

	additional_tags = {
		Name = "grafana-server"
		consul_server 	= "false"
	}
}

module "bastion-server" {
	source 				= "./instances/bastion"
	vpc_id 				= module.vpc.vpc_id
	number_of_instances = 1
	subnets_id 			= "${module.vpc.public_subnets[*]}"
	key_name 			= "${module.vpc.pem_key_name}"

	ec2_instance_security_groups = ["${module.vpc.bastion_server_sg}"]

	additional_tags = {
		Name = "bastion-server"
	}
}

module "alb" {
	source 							= "./loadbalancer"
	vpc_id 							= module.vpc.vpc_id
	subnets_id 						= "${module.vpc.public_subnets[*]}"

	ec2_instance_security_groups 	= ["${module.vpc.consul_servers_sg}","${module.vpc.jenkins_server_sg}", "${module.vpc.prometheus_server_sg}", "${module.vpc.grafana_server_sg}"]
	consul_servers_target_group 	= module.consul-servers.instance_id
	jenkins_server_target_group 	= module.jenkins-server.instance_id
	prometheus_server_target_group	= module.prometheus-server.instance_id
	grafana_server_target_group		= module.grafana-server.instance_id
	
}