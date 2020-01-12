variable "region" {
  default = "nyc1"
}

provider "digitalocean" {
  // token automatically picked up using env variables
}

resource "digitalocean_ssh_key" "nickmacbook" {
  name = "nickmacbook"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC79ZDnG6yI322Qw0OopaaZFVSjxbDtq9mYhycSM4Y1mc19sCjLUhjZHsPNEq/28x0uEUOpwDSA8q1V3HXmcCYRqFZa75tpvh3xytZw6Y5+e3tfCBbQIYRLROn/Xnz7tMo4EhSPpX0zPrx+Bese5bojtLmVokLkPTWZD6EMj1nqZ+C2Bm3RPShlfCoopS/Ivj1vszLEDvPsiVcUz0U2BD0aqM2OXG2TFWJS4kDvOrvwChNEinPwR/eC+ELz4XP9LLdZCx05r3XrlcqMPm1OF0WaA8Z2l1hxnfsDvdiiJNlpWsqNiTGSJeLyakP7BAe7DtCETZzQhM/CwiNmnXnFqtkR nick@nickMacbookPro"
}

resource "digitalocean_kubernetes_cluster" "hellok8s" {
  name    = "hellok8s"
  region  = "nyc1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.16.2-do.2"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 1
  }
}

output "set_context_command" {
  value = "doctl k c kubeconfig save \"$(doctl k c list | grep hello | awk '{print $1}')\" --set-current-context"
}