
data "template_file" "consul_agent" {
    # count    = var.number_of_instances
    template    = "${file("../configuration/scripts/consul_agent.sh.tpl")}"
    vars        = {
        consul_version  = "1.8.5"
        datacenter_name = "mid-project"
        # node_name       = var.consul_node_name-${count.index + 1}
    }
}

data "template_file" "consul_server" {
    # count    = var.number_of_instances
    template    = "${file("../configuration/scripts/consul_server.sh.tpl")}"
    vars        = {
        consul_version  = "1.8.5"
        datacenter_name = "mid-project"
        # node_name       = "${var.consul_node_name}-${count.index + 1}"
    }
}

data "template_file" "jenkins_server" {
    template = "${file("../configuration/scripts/jenkins_server.sh.tpl")}"
}

data "template_file" "jenkins_agent" {
    template = "${file("../configuration/scripts/jenkins_agent.sh.tpl")}"
}

data "template_file" "ansible_server" {
    template  = "${file("../configuration/scripts/ansible_server.sh.tpl")}"
}

data "template_file" "prometheus_server" {
    template  = "${file("../configuration/scripts/prometheus_server.sh.tpl")}"
    vars      = {
        prometheus_dir      = "/opt/prometheus"
        prometheus_conf_dir = "/etc/prometheus"
        prometheus_version  = "2.32.1"
    }
}

data "template_file" "grafana_server" {
    template = "${file("../configuration/scripts/grafana_server.sh.tpl")}"
    vars      = {
        grafana_version  = "8.3.3"
    }
}

data "template_file" "node_exporter" {
    template = "${file("../configuration/scripts/node_exporter.sh.tpl")}"
    vars      = {
        node_exporter_version = "0.18.0"
    }
}

data "template_cloudinit_config" "consul_server" {
    part {
        content = "${data.template_file.consul_server.rendered}"
    }
    part {
        content = "${data.template_file.node_exporter.rendered}"
    }
}

data "template_cloudinit_config" "jenkins_server" {
    part {
        content = "${data.template_file.consul_agent.rendered}"
    }
    part {
        content = "${data.template_file.jenkins_server.rendered}"
    }
    part {
        content = "${data.template_file.node_exporter.rendered}"
    }
}

data "template_cloudinit_config" "jenkins_agent" {
    part {
        content = "${data.template_file.consul_agent.rendered}"
    }
    part {
        content = "${data.template_file.jenkins_agent.rendered}"
    }
    part {
        content = "${data.template_file.node_exporter.rendered}"
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
}

data "template_cloudinit_config" "grafana_server" {
    part {
        content = "${data.template_file.consul_agent.rendered}"
    }
    part {
        content = "${data.template_file.node_exporter.rendered}"
    }
    part {
        content = "${data.template_file.grafana_server.rendered}"
    }
}