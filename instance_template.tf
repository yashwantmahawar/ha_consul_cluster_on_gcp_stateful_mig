resource "random_string" "random" {
  length  = 4
  lower   = true
  upper   = false
  special = false
}

resource "google_compute_instance_template" "default" {
  name        = "consul-cluster-01-${substr(sha256(file("${path.module}/startup_script.sh")), 0, 4)}"
  description = "This template is used to create consul cluster instances."
  tags        = ["allow-ssh", "allow-health-check", "consul-cluser-01", "allow-dns"]

  # Root disk
  disk {
    disk_size_gb = "20"
    disk_type    = "pd-standard"
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }
  # External stateful disk
  disk {
    disk_size_gb = "50"
    disk_type    = "pd-standard"
    auto_delete  = false
    boot         = false
    device_name  = "data-disk"
  }
  machine_type = "e2-medium"

  network_interface {
    network = "default"
  }
  service_account {
    email  = google_service_account.consul-01.email
    scopes = ["cloud-platform"]
  }
  metadata = {
    startup-script  = data.template_file.startup_script.rendered
    shutdown-script = data.template_file.shutdown_script.rendered
  }

  lifecycle {
    create_before_destroy = true
  }
}