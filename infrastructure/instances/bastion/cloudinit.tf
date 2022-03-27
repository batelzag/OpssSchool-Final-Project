
data "template_file" "consul_agent" {
    template    = "${file("../configuration/Templates/consul_agent.sh.tpl")}"
    vars        = {
        consul_version  = "1.11.3"
        datacenter_name = "final-project"
        node_name       = "${var.instance_name}"
    }
}

data "template_file" "bastion_server" {
    template  = "${file("../configuration/Templates/bastion_server.sh.tpl")}"
}

data "template_file" "node_exporter" {
    template = "${file("../configuration/Templates/node_exporter.sh.tpl")}"
    vars      = {
        node_exporter_version = "0.18.0"
    }
}

data "template_file" "filebeat" {
    template = "${file("../configuration/Templates/filebeat.sh.tpl")}"
    vars      = {
        filebeat_version = "7.11.0"
    }
}

data "template_cloudinit_config" "bastion_server" {
    part {
        content = "${data.template_file.consul_agent.rendered}"
    }
    part {
        content = "${data.template_file.filebeat.rendered}"
    }
    part {
        content = "${data.template_file.node_exporter.rendered}"
    }
    part {
        content = "${data.template_file.bastion_server.rendered}"
    }
}