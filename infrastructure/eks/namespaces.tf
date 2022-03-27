resource "kubernetes_namespace" "consul" {
  metadata {
    annotations = {
      name = "consul"
    }
    labels = {
      mylabel = "consul"
    }
    name = "consul"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }
    labels = {
      mylabel = "monitoring"
    }
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "logging" {
  metadata {
    annotations = {
      name = "logging"
    }
    labels = {
      mylabel = "logging"
    }
    name = "logging"
  }
}