resource "google_compute_region_backend_service" "udp" {
  name     = "consul-cluster-01-udp"
  protocol = "UDP"

  timeout_sec           = 10
  load_balancing_scheme = "INTERNAL"
  region                = var.region

  backend {
    group          = google_compute_instance_group_manager.instance_group_manager.instance_group
    description    = "Internal http load balancer consul cluster backend service UDP"
    balancing_mode = "CONNECTION"
    failover       = false
  }
  health_checks = [google_compute_health_check.http.self_link]
}
