
data "template_file" "consul_agent" {
    template    = "${file("../configuration/templates/consul_agent.sh.tpl")}"
    vars        = {
        consul_version  = "1.8.5"
        datacenter_name = "mid-project"
        node_name       = "${var.instance_name}"
    }
}

data "template_file" "ansible_server" {
    template  = "${file("../configuration/templates/ansible_server.sh.tpl")}"
}

data "template_file" "node_exporter" {
    template = "${file("../configuration/templates/node_exporter.sh.tpl")}"
    vars      = {
        node_exporter_version = "0.18.0"
    }
}

data "template_file" "filebeat" {
    template = "${file("../configuration/templates/filebeat.sh.tpl")}"
    vars      = {
        filebeat_version = "7.11.0"
        elk_host         = "${var.elk_private_ip}"
    }
}

data "template_cloudinit_config" "ansible_server" {
    part {
        content = "${data.template_file.consul_agent.rendered}"
    }
    part {
        content = "${data.template_file.ansible_server.rendered}"
    }
    part {
        content = "${data.template_file.node_exporter.rendered}"
    }
    part {
        content = "${data.template_file.filebeat.rendered}"
    }
}