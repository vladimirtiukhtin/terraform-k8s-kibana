resource "kubernetes_deployment_v1" "kibana" {

  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = {}
    labels      = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.selector_labels
    }

    template {

      metadata {
        labels = merge(local.labels, { "configmap-hash" = md5(kubernetes_config_map_v1.kibana_yaml.data["kibana.yml"]) })
      }

      spec {

        security_context {
          run_as_user  = var.user_id
          run_as_group = var.group_id
          fs_group     = var.group_id
        }

        affinity {
          dynamic "node_affinity" {
            for_each = var.node_affinity != null ? { node_affinity = var.node_affinity } : {}
            content {
              dynamic "required_during_scheduling_ignored_during_execution" {
                for_each = node_affinity.value["kind"] == "required" ? { node_selector_term = {} } : {}
                content {
                  node_selector_term {
                    match_expressions {
                      key      = node_affinity.value["label"]
                      operator = "In"
                      values   = [node_affinity.value["value"]]
                    }
                  }
                }
              }
              dynamic "preferred_during_scheduling_ignored_during_execution" {
                for_each = node_affinity.value["kind"] == "preferred" ? { node_selector_term = {} } : {}
                content {
                  weight = 1
                  preference {
                    match_expressions {
                      key      = node_affinity.value["label"]
                      operator = "In"
                      values   = [node_affinity.value["value"]]
                    }
                  }
                }
              }
            }
          }
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key      = "app.kubernetes.io/name"
                  operator = "In"
                  values   = [var.name]
                }
                match_expressions {
                  key      = "app.kubernetes.io/instance"
                  operator = "In"
                  values   = [var.instance]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        container {
          name              = var.name
          image             = "${var.image_name}:${var.image_tag}"
          image_pull_policy = var.image_tag == "latest" ? "Always" : "IfNotPresent"

          security_context {
            run_as_user  = var.user_id
            run_as_group = var.group_id
          }

          dynamic "env" {
            for_each = var.extra_env
            content {
              name  = env.key
              value = env.value
            }
          }

          port {
            name           = "http"
            protocol       = "TCP"
            container_port = local.kibana_config["server.port"]
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "300m"
              memory = "1024Mi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/usr/share/kibana/config/kibana.yml"
            sub_path   = "kibana.yml"
            read_only  = true
          }

          dynamic "volume_mount" {
            for_each = var.elasticsearch_ca != null ? { pki = {} } : {}
            content {
              name       = "config"
              mount_path = "/usr/share/kibana/config/ca.crt"
              sub_path   = "ca.crt"
              read_only  = true
            }
          }

          readiness_probe {
            period_seconds        = 10
            initial_delay_seconds = 60
            success_threshold     = 1
            failure_threshold     = 3
            timeout_seconds       = 3

            http_get {
              scheme = "HTTP"
              path   = "${lookup(local.kibana_config, "server.basePath", "")}/status"
              port   = "http"
            }
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.kibana_yaml.metadata.0.name
          }
        }

        dynamic "toleration" {
          for_each = {
            for toleration in var.tolerations : toleration["key"] => toleration
          }
          content {
            key      = toleration.key
            operator = toleration.value["operator"]
            value    = toleration.value["value"]
            effect   = toleration.value["effect"]
          }
        }

      }

    }

  }
  wait_for_rollout = var.wait_for_rollout
}
