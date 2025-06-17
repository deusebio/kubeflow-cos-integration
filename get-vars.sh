#!/bin/bash

CURRENT_CONTROLLER=$(cat ~/.local/share/juju/controllers.yaml | yq .current-controller)

export TF_VAR_JUJU_CONTROLLER_IPS=$(cat ~/.local/share/juju/controllers.yaml | yq ".controllers.${CURRENT_CONTROLLER}.api-endpoints" | sed 's/\[\(.*\)\]/\1/g' | sed "s/'//g")
export TF_VAR_JUJU_USERNAME=$(cat ~/.local/share/juju/accounts.yaml| yq ".controllers.${CURRENT_CONTROLLER}.user")
export TF_VAR_JUJU_PASSWORD=$(cat ~/.local/share/juju/accounts.yaml| yq ".controllers.${CURRENT_CONTROLLER}.password")
export TF_VAR_JUJU_CA_CERTIFICATE=$(cat ~/.local/share/juju/controllers.yaml | yq ".controllers.${CURRENT_CONTROLLER}.ca-cert" | base64)
export TF_VAR_K8S_CLOUD=$(cat ~/.local/share/juju/controllers.yaml | yq ".controllers.${CURRENT_CONTROLLER}.cloud")
export TF_VAR_K8S_CREDENTIAL=$TF_VAR_K8S_CLOUD

export TF_VAR_HTTP_PROXY=$HTTP_PROXY
export TF_VAR_HTTPS_PROXY=$HTTPS_PROXY

CLUSTER_CIDR=$(cat /var/snap/microk8s/current/args/kube-proxy | grep cluster-cidr | sed 's/^[^=]*=//')
SERVICE_CLUSTER_IP_RANGE=$(cat /var/snap/microk8s/current/args/kube-apiserver | grep service-cluster-ip-range | sed 's/^[^=]*=//')
NODE_INTERNAL_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
HOSTNAME=$(hostname)

export TF_VAR_NO_PROXY=$CLUSTER_CIDR,$SERVICE_CLUSTER_IP_RANGE,127.0.0.1,localhost,$NODE_INTERNAL_IP/24,$HOSTNAME,.svc,.local,.kubeflow
