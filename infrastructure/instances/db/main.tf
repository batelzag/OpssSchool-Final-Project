resource "aws_db_instance" "db-instance" {
    engine                  = "postgres"
    engine_version          = "12.9"
    instance_class          = var.instance_type
    identifier              = var.db_name
    name                    = var.db_name
    port                    = var.db_port_number
    username                = var.db_username
    password                = var.db_password
    parameter_group_name    = "default.postgres12"
    allocated_storage       = var.db_storage
    skip_final_snapshot     = true
    vpc_security_group_ids  = var.db_instance_security_groups
    db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.id

    tags = {
        Name = "${var.instance_name}"
    }
}

resource "aws_db_subnet_group" "db_subnet_group" {
    name       = "project-db-subnet-group"
    subnet_ids = "${var.subnets_id[*]}"

    tags = {
        Name = "OpsSchool Final project DB subnet group"
    }
}