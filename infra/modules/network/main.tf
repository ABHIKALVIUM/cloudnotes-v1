# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  description             = "CloudNotes custom VPC network"
}

# Subnet 1: Web tier subnet (public ingress / load balancer)
resource "google_compute_subnetwork" "web_subnet" {
  name                     = "${var.network_name}-web-subnet"
  ip_cidr_range            = var.web_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  description              = "Public web subnet for CloudNotes ingress and load balancing"
}

# Subnet 2: Application tier subnet (private compute instances)
resource "google_compute_subnetwork" "app_subnet" {
  name                     = "${var.network_name}-app-subnet"
  ip_cidr_range            = var.app_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  description              = "Private application tier subnet for CloudNotes instances"
}

# Subnet 3: Database tier subnet (private database instance)
resource "google_compute_subnetwork" "db_subnet" {
  name                     = "${var.network_name}-db-subnet"
  ip_cidr_range            = var.db_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  description              = "Private database tier subnet for CloudNotes managed database"
}

# Firewall rule: Allow HTTP/HTTPS traffic to web tier
resource "google_compute_firewall" "allow_web_ingress" {
  name        = "${var.network_name}-allow-web-ingress"
  network     = google_compute_network.vpc.name
  description = "Allow incoming HTTP/HTTPS traffic from internet to web tier"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-tier"]
}

# Firewall rule: Allow web tier to communicate with application tier
resource "google_compute_firewall" "allow_web_to_app" {
  name        = "${var.network_name}-allow-web-to-app"
  network     = google_compute_network.vpc.name
  description = "Allow web tier traffic to application backend tier"

  allow {
    protocol = "tcp"
    ports    = ["5000", "8080"]
  }

  source_ranges = [var.web_cidr]
  target_tags   = ["app-tier"]
}

# Firewall rule: Allow application tier to communicate with database tier
resource "google_compute_firewall" "allow_app_to_db" {
  name        = "${var.network_name}-allow-app-to-db"
  network     = google_compute_network.vpc.name
  description = "Allow application tier to communicate with database tier"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [var.app_cidr]
  target_tags   = ["db-tier"]
}

# Firewall rule: Allow SSH access via Google Cloud IAP
resource "google_compute_firewall" "allow_ssh_iap" {
  name        = "${var.network_name}-allow-ssh-iap"
  network     = google_compute_network.vpc.name
  description = "Allow SSH management access via Google Identity-Aware Proxy"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["app-tier", "web-tier"]
}
