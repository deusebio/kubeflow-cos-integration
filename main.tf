# Add COS
resource "juju_model" "cos" {
  name       = "cos"
  credential = var.K8S_CREDENTIAL
  cloud {
    name = var.K8S_CLOUD
  }
}

module "cos" {
  depends_on = [juju_model.cos]
  source     = "git::https://github.com/canonical/observability//terraform/modules/cos-lite"
  model      = juju_model.cos.name
}

module "kubeflow_bundle" {
  source     = "git::https://github.com/canonical/charmed-kubeflow-solutions//modules/kubeflow-mlflow?ref=track/1.10"
  create_model = true
  cos_configuration = true
}

