variable "region" {
  default = "nyc1"
}

variable "nicktestdomain" {
  default = "nicktestsstuff.xyz"
}

provider "digitalocean" {
  // token automatically picked up using env variables
}

resource "digitalocean_ssh_key" "nickmacbook" {
  name = "nickmacbook"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC79ZDnG6yI322Qw0OopaaZFVSjxbDtq9mYhycSM4Y1mc19sCjLUhjZHsPNEq/28x0uEUOpwDSA8q1V3HXmcCYRqFZa75tpvh3xytZw6Y5+e3tfCBbQIYRLROn/Xnz7tMo4EhSPpX0zPrx+Bese5bojtLmVokLkPTWZD6EMj1nqZ+C2Bm3RPShlfCoopS/Ivj1vszLEDvPsiVcUz0U2BD0aqM2OXG2TFWJS4kDvOrvwChNEinPwR/eC+ELz4XP9LLdZCx05r3XrlcqMPm1OF0WaA8Z2l1hxnfsDvdiiJNlpWsqNiTGSJeLyakP7BAe7DtCETZzQhM/CwiNmnXnFqtkR nick@nickMacbookPro"
}

resource "digitalocean_droplet" "atest" {
  image      = "ubuntu-18-04-x64"
  name       = "atest"
  region     = var.region
  size       = "s-1vcpu-1gb"
  ssh_keys   = [digitalocean_ssh_key.nickmacbook.id]
  monitoring = true
  private_networking = true

  connection {
    type = "ssh"
    user = "root"
    private_key = file("~/.ssh/id_rsa")
    host     = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update && apt-get install -y nginx"
    ]
  }
}

resource "digitalocean_floating_ip" "atest_floating_ip" {
  region = var.region
  droplet_id = digitalocean_droplet.atest.id
}

resource "digitalocean_domain" "nicktest" {
  name = var.nicktestdomain
}

resource "digitalocean_record" "nicktest_root" {
  domain = var.nicktestdomain
  name = "@"
  type = "A"
  value = digitalocean_floating_ip.atest_floating_ip.ip_address
}

resource "digitalocean_record" "nicktest_www" {
  domain = var.nicktestdomain
  name = "www"
  type = "A"
  value = digitalocean_floating_ip.atest_floating_ip.ip_address
}

output "atest_floating_ip" {
  value = digitalocean_floating_ip.atest_floating_ip.ip_address
}