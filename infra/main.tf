# ==============================================================================
# CloudNotes Infrastructure — Root Composition
# Composes the five core system layers through declared module interfaces:
# Network -> IAM -> Compute -> Database -> Storage
# Cross-module references construct the dependency graph automatically.
# ==============================================================================

# Layer 1: Network Foundation (VPC, Subnets: web/app/db, Firewall Rules)
module "network" {
  source       = "./modules/network"
  network_name = "cloudnotes-vpc"
  web_cidr     = var.web_cidr
  app_cidr     = var.app_cidr
  db_cidr      = var.db_cidr
  region       = var.region
}

# Layer 2: IAM & Security (Service Account & Least-Privilege Role Bindings)
module "iam" {
  source          = "./modules/iam"
  project_id      = var.project_id
  sa_account_id   = "cloudnotes-app-sa"
  sa_display_name = "CloudNotes Application Service Account"
}

# Layer 3: Compute Tier (CloudNotes VM Instance placed in App Subnet with IAM SA)
module "compute" {
  source        = "./modules/compute"
  instance_name = var.instance_name
  machine_type  = var.machine_type
  zone          = var.zone
  subnet_id     = module.network.subnet_id # Network output -> Compute input
  sa_email      = module.iam.app_sa_email  # IAM output -> Compute input
}

# Layer 4: Database Tier (Managed Cloud SQL PostgreSQL Instance on Private Network)
module "database" {
  source           = "./modules/database"
  db_instance_name = var.db_instance_name
  db_name          = var.db_name
  region           = var.region
  network_id       = module.network.network_id # Network output -> Database input
}

# Layer 5: Storage Tier (Cloud Storage Bucket for Static Assets & Uploads)
module "storage" {
  source      = "./modules/storage"
  bucket_name = var.bucket_name
  location    = "US"
}
