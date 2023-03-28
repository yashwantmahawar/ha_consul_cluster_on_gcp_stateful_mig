resource "google_compute_firewall" "allow_dns" {
  name        = "allow-dns-for-consul"
  network     = "default"
  description = "Allowing google DNS server to reach consul cluster nodes."

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = ["35.199.192.0/19"]
  target_tags   = ["allow-dns"]
}

# allow all access from health check ranges
resource "google_compute_firewall" "fw_hc" {
  name          = "l4-ilb-fw-allow-hc"
  direction     = "INGRESS"
  network       = "default"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20", "209.85.152.0/22", "209.85.204.0/22"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}