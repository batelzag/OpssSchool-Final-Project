# Install Helm chart for consul
resource "helm_release" "consul" {
  repository = "https://helm.releases.hashicorp.com"
  name       = "consul"
  chart      = "consul"
  namespace  = "consul"

  values = [
    "${file("../configuration/Kubernetes/consul-helm/values.yaml")}"
  ]

  set {
    name  = "global.name"
    value = "consul"
  }

  depends_on = [
    kubernetes_namespace.consul
  ]
}

# Update the Corefile in the coredns configmap to forward dns queries to consul
resource "kubectl_manifest" "coredns" {
  yaml_body = file("../configuration/Kubernetes/consul-helm/CoreDNS.yaml")
  force_new = true
}

# Configure filebeat
resource "kubectl_manifest" "filebeat" {
  yaml_body = file("../configuration/Kubernetes/filebeat/filebeat-config.yml")
  force_new = true

depends_on = [
    kubernetes_namespace.logging
  ]
}

# Install helm chart for node exporter
resource "helm_release" "node_exporter" {
  repository = "https://prometheus-community.github.io/helm-charts"
  name       = "prometheus-node-exporter"
  chart      = "prometheus-node-exporter"
  namespace  = "monitoring"

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}