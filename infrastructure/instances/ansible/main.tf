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
  # user_data                   = file(var.configuration_script) #file("${path.module}/jenkins_server.sh")
  user_data                   = var.user_data_script

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
    source      = "../configuration/roles/jenkins_install_plugins" 
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

  tags = var.additional_tags
}