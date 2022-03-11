# Output the consul instances id
output "instance_id" {
    value       = "${aws_instance.ec2-instance.*.id}"
    description = "the id of the instnaces"
}