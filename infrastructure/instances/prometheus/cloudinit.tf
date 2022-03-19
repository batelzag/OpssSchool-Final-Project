
data "template_file" "consul_agent" {
    template    = "${file("../configuration/templates/consul_agent.sh.tpl")}"
    vars        = {
        consul_version  = "1.11.3"
        datacenter_name = "mid-project"
        node_name       = "${var.instance_name}"
    }
}

data "template_file" "prometheus_server" {
    template  = "${file("../configuration/templates/prometheus_server.sh.tpl")}"
    vars      = {
        prometheus_dir      = "/opt/prometheus"
        prometheus_conf_dir = "/etc/prometheus"
        prometheus_version  = "2.32.1"
    }
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
    }
}

data "template_cloudinit_config" "prometheus_server" {
    part {
        content = "${data.template_file.consul_agent.rendered}"
    }
    part {
        content = "${data.template_file.node_exporter.rendered}"
    }
    part {
        content = "${data.template_file.prometheus_server.rendered}"
    }
    part {
        content = "${data.template_file.filebeat.rendered}"
    }
}