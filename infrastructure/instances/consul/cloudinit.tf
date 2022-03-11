data "template_file" "consul_server" {
    count       = var.number_of_instances
    template    = "${file("../configuration/templates/consul_server.sh.tpl")}"
    vars        = {
        consul_version  = "1.8.5"
        datacenter_name = "mid-project"
        node_name       = "${var.instance_name}-${count.index+1}"
    }
}

data "template_file" "node_exporter" {
    count    = var.number_of_instances
    template = "${file("../configuration/templates/node_exporter.sh.tpl")}"
    vars     = {
        node_exporter_version = "0.18.0"
    }
}

data "template_file" "filebeat" {
    count    = var.number_of_instances
    template = "${file("../configuration/templates/filebeat.sh.tpl")}"
    vars     = {
        filebeat_version = "7.11.0"
        elk_host         = "${var.elk_private_ip}"
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