# Output the bastion server public ip address
output "bastion_public_ip" {
    value       = "${aws_instance.ec2-instance.*.public_ip}"
    description = "the public ip of the instnace"
}