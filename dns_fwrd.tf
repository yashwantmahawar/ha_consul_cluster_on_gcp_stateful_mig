resource "google_dns_managed_zone" "dns-forwarding-zone" {
  name        = "consul-cluster-01-fwrd"
  dns_name    = "dc1.consul."
  description = "consul cluster 01 dns forwarding"
  visibility = "private"

  labels = {
    consul-cluster = "consul-cluster-01"
  }

  private_visibility_config {
    networks {
      network_url = "${data.google_project.project.id}/global/networks/default"
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address    = google_compute_address.this.address
      forwarding_path = "default"
    }
  }
}