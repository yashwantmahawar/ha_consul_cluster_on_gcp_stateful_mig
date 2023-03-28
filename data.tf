data "template_file" "startup_script" {
  template = file("${path.module}/startup_script.sh")
  vars = {
    consul_version = var.consul_version
    dns_static_ip  = google_compute_address.this.address
  }
}

data "template_file" "shutdown_script" {
  template = file("${path.module}/shutdown_script.sh")
  vars = {
    consul_version = var.consul_version
  }
}

data "google_project" "project" {}