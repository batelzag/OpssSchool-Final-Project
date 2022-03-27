data "template_file" "consul_server" {
    count       = var.number_of_instances
    template    = "${file("../configuration/Templates/consul_server.sh.tpl")}"
    vars        = {
        consul_version  = "1.11.3"
        datacenter_name = "final-project"
        node_name       = "${var.instance_name}-${count.index+1}"
    }
}

data "template_file" "node_exporter" {
    count    = var.number_of_instances
    template = "${file("../configuration/Templates/node_exporter.sh.tpl")}"
    vars     = {
        node_exporter_version = "0.18.0"
    }
}

data "template_file" "filebeat" {
    count    = var.number_of_instances
    template = "${file("../configuration/Templates/filebeat.sh.tpl")}"
    vars     = {
        filebeat_version = "7.11.0"
    }
}

data "template_cloudinit_config" "consul_server" {
    count    = var.number_of_instances
    part {
        content = element(data.template_file.consul_server.*.rendered, count.index)
    }
    part {
        content = element(data.template_file.node_exporter.*.rendered, count.index)
    }
    part {
        content = element(data.template_file.filebeat.*.rendered, count.index)
    }
}