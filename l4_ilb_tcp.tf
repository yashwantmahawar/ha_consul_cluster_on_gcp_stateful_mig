resource "google_compute_forwarding_rule" "this" {
  name                  = "consul-cluster-01-tcp"
  region                = var.region
  subnetwork            = "${data.google_project.project.id}/regions/${var.region}/subnetworks/default"
  allow_global_access   = true
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.this.id
  ip_address            = google_compute_address.this.address
  ip_protocol           = "TCP"
  ports                 = ["53", "8301"]
  all_ports             = false
}