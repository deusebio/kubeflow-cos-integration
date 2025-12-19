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
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=4199a1db2eda376fad1bd2ca8a4c9e109d0ac059"
  model = juju_model.cos.name
  channel = "1/stable"
  use_tls = false
}

resource "juju_model" "kubeflow" {
  name       = "kubeflow"
  credential = var.K8S_CREDENTIAL
  cloud {
    name = var.K8S_CLOUD
  }
  config = {
    juju-http-proxy = var.HTTP_PROXY
    juju-https-proxy = var.HTTPS_PROXY
    no-proxy = var.NO_PROXY
  }
}

module "kubeflow_bundle" {
  depends_on = [juju_model.kubeflow]
  source     = "git::https://github.com/canonical/charmed-kubeflow-solutions//modules/kubeflow-mlflow?ref=kf-8292-replace-grafana-agent-k8s"
  create_model = false
  cos_configuration = true
  http_proxy = var.HTTP_PROXY
  https_proxy = var.HTTPS_PROXY
  no_proxy = var.NO_PROXY
}


## COS <> KUBEFLOW INTEGRATIONS

resource "juju_integration" "agent_grafana_dashboards" {
  model =  module.kubeflow_bundle.model

  application {
    name     = module.kubeflow_bundle.grafana_agent_k8s.app_name
    endpoint = "grafana-dashboards-provider"
  }

  application {
    offer_url = module.cos.offers.grafana_dashboards.url
  }

}

resource "juju_integration" "agent_prometheus" {
  model = module.kubeflow_bundle.model

  application {
    name     = module.kubeflow_bundle.grafana_agent_k8s.app_name
    endpoint = "send-remote-write"
  }

  application {
    offer_url = module.cos.offers.prometheus_receive_remote_write.url
  }

}

resource "juju_integration" "agent_loki" {
  model = module.kubeflow_bundle.model

  application {
    name     = module.kubeflow_bundle.opentelemetry_collector_k8s.app_name
    endpoint = "send-loki-logs"
  }

  application {
    offer_url = module.cos.offers.loki_logging.url
  }

}

