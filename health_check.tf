resource "google_compute_health_check" "http" {
  name = "consul-cluster-01-hc"

  check_interval_sec  = 10
  healthy_threshold   = 3
  timeout_sec         = 5
  unhealthy_threshold = 2

  http_health_check {
    port         = "8500"
    request_path = "/v1/health/checks/consul?dc=dc1"
  }
}