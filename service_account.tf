resource "google_service_account" "consul-01" {
  account_id   = "consul-cluster-01"
  display_name = "consul cluster 01"
}

# Required to do consul discovery
resource "google_project_iam_member" "consul_compute_viewer" {
  project = data.google_project.project.number
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.consul-01.email}"
}