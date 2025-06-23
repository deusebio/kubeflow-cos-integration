terraform {
  required_version = ">=1.0"

  required_providers {
    juju = {
      source  = "juju/juju"
  	  version = ">=0.16.0,<=0.19"
	}

  }
}

provider "juju" {
  controller_addresses = var.JUJU_CONTROLLER_IPS
  username         	= var.JUJU_USERNAME
  password         	= var.JUJU_PASSWORD
  ca_certificate   	= base64decode(var.JUJU_CA_CERTIFICATE)
}
