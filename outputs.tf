output "path" {
  description = "Where cosign is on each host."
  value       = "/usr/local/bin/cosign"
}

output "version" {
  description = "The cosign release installed."
  value       = var.cosign_version
}
