variable "hosts" {
  type        = any
  description = "Hosts to configure: a map of names to addresses, or to host objects with an address and optional host_key, user, port, private_key_file or jump_hosts."
}

variable "ssh_user" {
  type        = string
  default     = "root"
  description = "User to log in as."
}

variable "ssh_port" {
  type        = number
  default     = 22
  description = "SSH port."
}

variable "ssh_private_key_file" {
  type        = string
  default     = null
  description = "Path to a private key. When null, Conn3x uses the SSH agent."
}

variable "ssh_known_hosts_file" {
  type        = string
  default     = null
  description = "known_hosts file to check host keys against. When null, ~/.ssh/known_hosts."
}

variable "ssh_become" {
  type        = bool
  default     = false
  description = "Run commands as root through sudo."
}

variable "cosign_version" {
  type        = string
  default     = "3.1.4"
  description = "cosign release to install from GitHub, without the leading v. Change checksums with it."

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.cosign_version))
    error_message = "cosign_version is a release number such as \"3.1.4\"."
  }
}

variable "checksums" {
  type        = map(string)
  description = "SHA-256 of the release binary for each architecture, from the release's cosign_checksums.txt. Change these with cosign_version."
  default = {
    amd64 = "424e2c97d0b45fd7a6b608a87f090f35633f4c23ece5f092d48bba11aaf4bbfa"
    arm64 = "ade83b7aac62e131cacfe96d958948b2150cc9efec46a570a2649b8e27dedad2"
  }

  validation {
    condition     = alltrue([for a in ["amd64", "arm64"] : can(regex("^[0-9a-f]{64}$", lookup(var.checksums, a, "")))])
    error_message = "checksums needs a lowercase hex SHA-256 for both amd64 and arm64."
  }
}
