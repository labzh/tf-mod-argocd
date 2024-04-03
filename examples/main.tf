module "argocd" {
  source       = "git@github.com:lightspeedhq/tf-argocd-module?ref=main"
  domain       = "argocd.lightspeed.app"
  github_oauth = {
    enabled       = true
    client_id     = "123"
    client_secret = "123abc"
    organization  = "lightspeed"
  }
  github_app_credentials = {
    id            = "123456"
    installations = [
      {
        id           = "654321"
        organization = "lightspeed"
      }
    ]
    private_key = <<EOT
        -----BEGIN RSA PRIVATE KEY-----
        -----END RSA PRIVATE KEY-----
    EOT
  }
  bootstrap_app = {
    enabled         = true
    url             = "https://github.com/argoproj/argocd-example-apps"
    target_revision = "master"
    path            = "apps"
  }
  values_files = ["${path.module}/argocd-config.yaml"]
  redis        = {
    host     = "125.65.64.3"
    username = "test"
    password = "test"
  }
}
