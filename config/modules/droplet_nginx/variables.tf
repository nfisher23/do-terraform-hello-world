variable "name" {
  type = string
  description = "The name of the droplet to create"
}

variable "region" {
  type = string
  description = "The digital ocean region to pass in"
}

variable "ssh_keys" {
  type = list(string)
  description = "The ssh key ids to include"
}
