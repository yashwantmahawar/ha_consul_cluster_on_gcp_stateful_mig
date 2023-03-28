resource "google_compute_address" "this" {
  name         = "consul-cluster-01-farwarding"
  address_type = "INTERNAL"
  purpose      = "SHARED_LOADBALANCER_VIP"
  address      = ""
  subnetwork   = "${data.google_project.project.id}/regions/${var.region}/subnetworks/default"
  description  = "consul-cluster-01-farwarding"
  region       = var.region
}
