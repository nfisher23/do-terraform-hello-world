resource "digitalocean_droplet" "atest" {
  image      = "ubuntu-18-04-x64"
  name       = "atest"
  region     = var.region
  size       = "s-1vcpu-1gb"
  ssh_keys   = var.ssh_keys
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
      "sleep 30", // to avoid lock related problems after server boots up
      "apt-get install -y nginx"
    ]
  }
}