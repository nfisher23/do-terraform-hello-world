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
  version = "1.16.2-do.1"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 1
  }
}

provider kubernetes {
  host = digitalocean_kubernetes_cluster.hellok8s.endpoint
  token = digitalocean_kubernetes_cluster.hellok8s.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.hellok8s.kube_config[0].cluster_ca_certificate
  )
}

resource "kubernetes_deployment" "load_balance" {
  metadata {
    name = "hello-world"
    labels = {
      App = "load-balancer-example"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "load-balancer-example"
      }
    }
    template {
      metadata {
        labels = {
          App = "load-balancer-example"
        }
      }
      spec {
        container {
          name = "hello-world"
          image = "gcr.io/google-samples/node-hello:1.0"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "my_service" {
  metadata {
    name = "load-balancer-nginx"
  }
  spec {
    selector = {
      App = kubernetes_deployment.load_balance.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.my_service.load_balancer_ingress[0].ip
}

# proof:
# curl $(terraform output lb_ip):8080