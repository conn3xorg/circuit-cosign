variable "port" {
  type    = number
  default = 2222
}

module "cosign" {
  source = "../.."

  hosts                = { box = "127.0.0.1" }
  ssh_port             = var.port
  ssh_private_key_file = "./id_ed25519"
  ssh_known_hosts_file = "./known_hosts"
}

output "path" {
  value = module.cosign.path
}
