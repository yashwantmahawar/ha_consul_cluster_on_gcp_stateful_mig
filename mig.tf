resource "google_compute_instance_group_manager" "instance_group_manager" {
  name               = "consul-cluster"
  base_instance_name = "consul-cluster"
  zone               = var.zone
  target_size        = "3"


  version {
    instance_template = google_compute_instance_template.default.id
  }
  stateful_disk {
    device_name = "data-disk"
    delete_rule = "ON_PERMANENT_INSTANCE_DELETION"
  }
}

