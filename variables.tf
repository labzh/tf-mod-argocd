variable "namespace" {
  type        = string
  description = "Namespace in which to deploy ArgoCD"
  default     = "argocd"
}

variable "chart_version" {
  type        = string
  default     = "5.51.4"
  description = "ArgoCD helm chart version to deploy"
}

variable "admin" {
  type = object({
    enabled  = bool
    password = string
  })
  default = {
    enabled  = false
    password = null
  }
  description = "Enable admin user, if enabled, set a password or create a random one"
}

variable "github_app_credentials" {
  type = object({
    id            = string
    installations = list(object({
      id           = string
      organization = string
    }))
    private_key = string
  })
  description = "Github app credentials which will be able to access all Github repositories that contains charts to deploy with ArgoCD"
}

variable "github_oauth" {
  type = object({
    enabled       = optional(bool, false)
    client_id     = optional(string, "")
    client_secret = optional(string, "")
    organization  = optional(string, "")
  })
  description = "Github oauth integration"
}

variable "repositories" {
  description = "A list of repository definitions"
  default     = []
  type        = list(object({
    url      = string
    name     = string
    type     = string
    username = string
    password = string
  }))
}

variable "values_files" {
  type        = list(string)
  default     = []
  description = "Path to values files be passed to the ArgoCD Helm Deployment"
}

variable "values" {
  default     = {}
  description = "A terraform map of extra values to pass to the ArgoCD Helm"
}

variable "bootstrap_app" {
  type = object({
    enabled         = optional(bool, false)
    name            = optional(string, "bootstrap-app")
    namespace       = optional(string, "argocd")
    url             = string
    target_revision = optional(string, "main")
    path            = optional(string, "./")
    values_file     = optional(string, "values.yaml")
  })
  description = "ArgoCD application that will be deployed after ArgoCD is installed"
}

variable "monitoring" {
  type = object({
    enabled = bool
  })
  default = {
    enabled = false
  }
  description = "Whether to enable exposing of ArgoCD metrics for Prometheus"
}

variable "domain" {
  type        = string
  description = "ArgoCD domain name"
}

variable "server_scaling" {
  description = "Resource and scaling spec for argocd-server pods"
  type        = object({
    resources = object({
      requests = object({
        cpu    = string
        memory = string
      }),
      limits = object({
        cpu    = string
        memory = string
      })
    }),
    autoscaling = object({
      min_replicas                         = string
      max_replicas                         = string
      target_memory_utilization_percentage = string
      target_cpu_utilization_percentage    = string
    })
  })
  default = {
    resources = {
      limits = {
        cpu    = "1"
        memory = "1Gi"
      },
      requests = {
        cpu    = "500m"
        memory = "512Mi"
      }
    },
    autoscaling = {
      min_replicas                         = "1"
      max_replicas                         = "10"
      target_memory_utilization_percentage = "50"
      target_cpu_utilization_percentage    = "50"
    }
  }
}

variable "repo_server_scaling" {
  description = "Resource and scaling spec for argocd-repo-server pods"
  type        = object({
    resources = object({
      requests = object({
        cpu    = string
        memory = string
      }),
      limits = object({
        cpu    = string
        memory = string
      })
    }),
    autoscaling = object({
      min_replicas                         = string
      max_replicas                         = string
      target_memory_utilization_percentage = string
      target_cpu_utilization_percentage    = string
    })
  })
  default = {
    resources = {
      limits = {
        cpu    = "1"
        memory = "1Gi"
      },
      requests = {
        cpu    = "500m"
        memory = "512Mi"
      }
    },
    autoscaling = {
      min_replicas                         = "1"
      max_replicas                         = "10"
      target_memory_utilization_percentage = "50"
      target_cpu_utilization_percentage    = "50"
    }
  }
}

variable "dex_scaling" {
  description = "Resource spec for argocd-dex-server pods"
  type        = object({
    resources = object({
      requests = object({
        cpu    = string
        memory = string
      }),
      limits = object({
        cpu    = string
        memory = string
      })
    })
  })
  default = {
    resources = {
      limits = {
        cpu    = "1"
        memory = "512Mi"
      },
      requests = {
        cpu    = "500m"
        memory = "256Mi"
      }
    }
  }
}
variable "controller_scaling" {
  description = "Resource spec for argocd-application-controller pods"
  type        = object({
    resources = object({
      requests = object({
        cpu    = string
        memory = string
      }),
      limits = object({
        cpu    = string
        memory = string
      })
    })
  })
  default = {
    resources = {
      limits = {
        cpu    = "1"
        memory = "2Gi"
      },
      requests = {
        cpu    = "500m"
        memory = "1Gi"
      }
    }
  }
}

variable "controller_args" {
  description = "Controller args overrides"
  type        = object({
    status_processors           = string
    operation_processors        = string
    app_resync_period           = string
    self_heal_timeout           = string
    repo_server_timeout_seconds = string
  })
  default = {
    status_processors           = "20"
    operation_processors        = "10"
    app_resync_period           = "180"
    self_heal_timeout           = "5"
    repo_server_timeout_seconds = "180"
  }
}

variable "redis" {
  description = "Redis configuration"
  type        = object({
    host     = string
    username = string
    password = string
    port     = optional(string, "6379")
  })
}
