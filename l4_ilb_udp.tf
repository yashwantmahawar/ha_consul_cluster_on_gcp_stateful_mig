resource "google_compute_forwarding_rule" "ilb_udp" {
  name                  = "consul-cluster-01-udp"
  region                = var.region
  subnetwork            = "${data.google_project.project.id}/regions/${var.region}/subnetworks/default"
  allow_global_access   = true
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.udp.id
  ip_address            = google_compute_address.this.address
  ip_protocol           = "UDP"
  ports                 = ["53"]
  all_ports             = false
}