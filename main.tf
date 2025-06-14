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
  source     = "git::https://github.com/deusebio/observability//terraform/modules/cos-lite?ref=wip-fix-kf-cos-integration"
  # source = "./observability/terraform/modules/cos-lite"
  model = juju_model.cos.name
}

module "kubeflow_bundle" {
  source     = "git::https://github.com/canonical/charmed-kubeflow-solutions//modules/kubeflow-mlflow?ref=track/1.10"
  create_model = true
  cos_configuration = true
}


## COS <> KUBEFLOW INTEGRATIONS

resource "juju_integration" "agent_grafana_dashboards" {
  model =  module.kubeflow_bundle.model

  application {
    name     = module.kubeflow_bundle.grafana_agent_k8s.app_name
    endpoint = "grafana-dashboards-provider"
  }

  application {
    offer_url = module.cos.offers.grafana
  }

}

resource "juju_integration" "agent_prometheus" {
  model = module.kubeflow_bundle.model

  application {
    name     = module.kubeflow_bundle.grafana_agent_k8s.app_name
    endpoint = "send-remote-write"
  }

  application {
    offer_url = module.cos.offers.prometheus
  }

}

resource "juju_integration" "agent_loki" {
  model = module.kubeflow_bundle.model

  application {
    name     = module.kubeflow_bundle.grafana_agent_k8s.app_name
    endpoint = "logging-consumer"
  }

  application {
    offer_url = module.cos.offers.loki
  }

}

