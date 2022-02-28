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

  tags = var.additional_tags
}