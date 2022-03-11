# Output the consul instances id
output "instance_id" {
    value       = "${aws_instance.ec2-instance.*.id}"
    description = "the id of the instnaces"
}

# Output the elk server private ip address
output "elk_private_ip" {
    value       = "${aws_instance.ec2-instance.*.private_ip}"
    description = "the private ip of the instnace"
}