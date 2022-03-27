# create ec2-instances 
resource "aws_instance" "ec2-instance" {
  count                       = var.number_of_instances
  ami                         = data.aws_ami.ubuntu-18.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = element(var.subnets_id,count.index)
  associate_public_ip_address = false
  vpc_security_group_ids      = var.ec2_instance_security_groups
  iam_instance_profile        = var.ec2_instance_iam_profile
  user_data                   = data.template_cloudinit_config.ansible_server.rendered

  tags = {
    Name = "${var.instance_name}"
    consul_server = "false"
  }

  provisioner "file" {
    source      = "${var.key_name}"
    destination = "/home/ubuntu/${var.key_name}"

    connection {
      host = self.private_ip
      type = "ssh"
      user = "ubuntu"
      private_key = file(var.key_name) 
      bastion_host = "${var.bastion_public_ip}"
      bastion_user = "ubuntu"
      bastion_private_key = file(var.key_name)
    } 
  }

  provisioner "file" {
    source      = "../configuration/Ansible-Roles/jenkins_install_plugins" 
    destination = "/home/ubuntu"

    connection {   
      host        = self.private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_name) 
      bastion_host = "${var.bastion_public_ip}"
      bastion_user = "ubuntu"
      bastion_private_key = file(var.key_name)    
    }  
	}

  provisioner "file" {
    source      = "../configuration/filebeat.yml" 
    destination = "/home/ubuntu/filebeat.yml"

    connection {   
      host        = self.private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_name) 
      bastion_host = "${var.bastion_public_ip}"
      bastion_user = "ubuntu"
      bastion_private_key = file(var.key_name)    
    }  
	}
}