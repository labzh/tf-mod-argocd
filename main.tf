locals {
  config_file = templatefile("${path.module}/argocd-config.yaml.tftpl", {
    argocd_url          = "https://${var.domain}"
    namespace           = var.namespace
    admin               = var.admin
    monitoring          = var.monitoring
    server_scaling      = var.server_scaling
    repo_server_scaling = var.repo_server_scaling
    dex_scaling         = var.dex_scaling
    controller_scaling  = var.controller_scaling
    controller_args     = var.controller_args
    redis               = var.redis
  })

  auth_file = templatefile("${path.module}/argocd-auth.yaml.tftpl", {
    oauth = var.github_oauth
  })

  apps_file = templatefile("${path.module}/argocd-apps.yaml.tftpl", {
    namespace     = var.namespace
    bootstrap_app = var.bootstrap_app
  })

  values = {
    configs = {
      repositories        = var.repositories
      credentialTemplates = {
        for installation in var.github_app_credentials.installations :
        "github-${installation.organization}-credentials" => {
          url                     = "https://github.com/${installation.organization}"
          githubAppID             = var.github_app_credentials.id
          githubAppInstallationID = installation.id
          githubAppPrivateKey     = var.github_app_credentials.private_key
        }
      }
    }
  }
}

resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = var.namespace
  }
}

# This resource allows us to change the admin password
# or remove the admin user/password entirely outside of terraform.
# - note: changing var.admin.password will cause helm to reinstall the helm chart, which will likely recreate admin
resource "null_resource" "argocd_password" {
  count = var.admin.enabled ? 1 : 0

  triggers = {
    origin = var.admin.password
    result = bcrypt(var.admin.password)
  }

  lifecycle {
    ignore_changes = [triggers["result"]]
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd_namespace.metadata[0].name
  version    = var.chart_version
  values     = concat(
    [local.config_file],
    var.github_oauth.enabled ? [local.auth_file] : [],
    [
      yamlencode(local.values), yamlencode(var.values)
    ],
    [
      for x in var.values_files : file(x)
    ]
  )

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.admin.enabled ? null_resource.argocd_password[0].triggers["result"] : ""
  }
}

resource "helm_release" "argocd_apps" {
  count      = var.bootstrap_app.enabled ? 1 : 0
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd_namespace.metadata[0].name
  version    = "1.4.1"
  values     = [
    local.apps_file
  ]

  depends_on = [
    helm_release.argocd
  ]
}
