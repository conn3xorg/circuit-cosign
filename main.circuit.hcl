# Facts give each host's architecture, which picks the release binary, and
# its distribution, so a host this circuit wasn't tested on stops at plan.
data "conn3x_host" "facts" {
  for_each = var.hosts

  ssh {
    host             = try(each.value.address, each.value)
    host_key         = try(each.value.host_key, null)
    user             = try(each.value.user, var.ssh_user)
    port             = try(each.value.port, var.ssh_port)
    private_key_file = try(each.value.private_key_file, var.ssh_private_key_file)
    jump_hosts       = try(each.value.jump_hosts, null)
    known_hosts_file = var.ssh_known_hosts_file
  }

  lifecycle {
    postcondition {
      condition     = (self.os_id == "ubuntu" && self.os_version == "24.04") || (self.os_id == "debian" && self.os_version == "13") || (self.os_id == "rocky" && startswith(self.os_version, "10.")) || (self.os_id == "fedora" && self.os_version == "45")
      error_message = "Host ${each.key} runs ${self.os_id} ${self.os_version}. This circuit supports Ubuntu 24.04, Debian 13, Rocky Linux 10 and Fedora 45."
    }
  }
}

locals {
  goarch = { x86_64 = "amd64", aarch64 = "arm64" }
  home   = "/opt/cosign/${var.cosign_version}"
}

circuit "cosign" {
  hosts = var.hosts

  ssh {
    user             = var.ssh_user
    port             = var.ssh_port
    private_key_file = var.ssh_private_key_file
    known_hosts_file = var.ssh_known_hosts_file
    become           = var.ssh_become
  }

  step "curl" {
    package {
      name = "curl"
    }
  }

  # The binary from the GitHub release, not the .deb or .rpm beside it, so
  # one checksum per architecture covers every distribution here.
  step "download" {
    download {
      url    = "https://github.com/sigstore/cosign/releases/download/v${var.cosign_version}/cosign-linux-${local.goarch[data.conn3x_host.facts[each.key].arch]}"
      sha256 = var.checksums[local.goarch[data.conn3x_host.facts[each.key].arch]]
      dest   = "${local.home}/cosign"
      mode   = "0755"
    }
  }

  step "link" {
    link {
      path   = "/usr/local/bin/cosign"
      target = "${local.home}/cosign"
    }
  }
}
