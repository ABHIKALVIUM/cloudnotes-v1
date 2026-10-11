resource "google_compute_instance" "app_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["app-tier"]
  description  = "CloudNotes application instance placed in the application subnet"

  boot_disk {
    initialize_params {
      image = var.image
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.subnet_id

    access_config {
      // Ephemeral public NAT IP for external web egress / public access
    }
  }

  service_account {
    email  = var.sa_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "CloudNotes application server initializing..."
  EOT
}
