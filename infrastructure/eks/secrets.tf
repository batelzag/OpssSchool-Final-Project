resource "kubernetes_secret" "kandula_db_credentials" {
  metadata {
    name = "kanduladb-credentials"
  }

  data = {
    username = "${var.db_username}"
    password = "${var.db_password}"
  }
  type = "Opaque"
}

resource "kubernetes_secret" "consul-gossip-encryption-key" {
  metadata {
    name      = "consul-gossip-encryption-key"
    namespace = "consul"
  }

  data = {
    key = "fwz6Zxm/TJfpyzOYHC9A1D+YJpCabdhU3FHU+ASWylI="
  }
  type = "Opaque"
}