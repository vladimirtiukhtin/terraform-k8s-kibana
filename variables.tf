variable "name" {
  description = "Common application name"
  type        = string
  default     = "kibana"
}

variable "instance" {
  description = "Common instance name"
  type        = string
  default     = "default"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "default"
}

variable "replicas" {
  description = "Number of cluster nodes. Recommended value is the one which equals number of kubernetes nodes"
  type        = number
  default     = 1
}

variable "user_id" {
  description = "Unix UID to apply to persistent volume"
  type        = number
  default     = 1000
}

variable "group_id" {
  description = "Unix GID to apply to persistent volume"
  type        = number
  default     = 1000
}

variable "image_name" {
  description = "Container image name including registry address. For images from Docker Hub short names can be used"
  type        = string
  default     = "docker.elastic.co/kibana/kibana"
}

variable "image_tag" {
  description = "Container image tag (version)"
  type        = string
  default     = "8.2.3"
}

variable "service_annotations" {
  description = ""
  type        = map(any)
  default     = {}
}

variable "elasticsearch_hosts" {
  description = ""
  type        = list(string)
  default = [
    "http://elasticsearch-0.elasticsearch:9200",
    "http://elasticsearch-1.elasticsearch:9200",
    "http://elasticsearch-2.elasticsearch:9200",
  ]
}

variable "elasticsearch_ca" {
  description = ""
  type        = string
  default     = null
}

variable "elasticsearch_ssl_verification_mode" {
  description = ""
  type        = string
  default     = "full"
}

variable "elasticsearch_credentials" {
  description = ""
  type = object({
    username = string
    password = string
  })
  default = null
}

variable "kibana_extra_config" {
  description = ""
  type        = map(any)
  default     = {}
}

variable "node_affinity" {
  description = ""
  type = object({
    kind  = string
    label = string
    value = string
  })
  default = null
}

variable "tolerations" {
  description = "List of node taints a pod tolerates"
  type = list(object({
    key      = optional(string)
    operator = optional(string, null)
    value    = optional(string, null)
    effect   = optional(string, null)
  }))
  default = []
}

variable "extra_env" {
  description = "Any extra environment variables to apply to MySQL StatefulSet"
  type        = map(string)
  default     = {}
}

variable "extra_labels" {
  description = "Any extra labels to apply to kubernetes resources"
  type        = map(string)
  default     = {}
}

variable "wait_for_rollout" {
  description = ""
  type        = bool
  default     = true
}
