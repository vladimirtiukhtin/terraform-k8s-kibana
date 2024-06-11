resource "kubernetes_config_map_v1" "kibana_yaml" {
  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = {}
    labels      = local.labels
  }
  data = merge(
    {
      "kibana.yml" = yamlencode(local.kibana_config)
    }, var.elasticsearch_ca != null ?
    {
      "ca.crt" = var.elasticsearch_ca
    } : {}
  )
}

locals {
  kibana_config = merge(
    {
      "server.host"         = "0.0.0.0"
      "server.port"         = 8080
      "elasticsearch.hosts" = var.elasticsearch_hosts
      "telemetry.optIn"     = false
    },
    var.elasticsearch_ca != null ? {
      "elasticsearch.ssl.certificateAuthorities" = "/usr/share/kibana/config/ca.crt"
      "elasticsearch.ssl.verificationMode"       = var.elasticsearch_ssl_verification_mode
    } : {},
    var.elasticsearch_credentials != null ? {
      "elasticsearch.username" = var.elasticsearch_credentials["username"]
      "elasticsearch.password" = var.elasticsearch_credentials["password"]
    } : {},
    var.kibana_extra_config
  )
}
