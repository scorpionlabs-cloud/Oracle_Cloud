##############################
# Root Orchestration
##############################

locals {
  landing_zone_name = var.landing_zone_name
}

# ---------- Identity / Compartments / IAM ----------
module "identity" {
  source                 = "./modules/identity"
  tenancy_ocid           = var.tenancy_ocid
  landing_zone_name      = local.landing_zone_name
  home_region            = var.home_region
  iam_admin_group_name   = var.iam_admin_group_name
  enable_security_zones  = var.enable_security_zones
  enable_cloud_guard     = var.enable_cloud_guard
}

# ---------- Networking (Hub-Spoke) ----------
module "networking" {
  source            = "./modules/networking"
  tenancy_ocid      = var.tenancy_ocid
  region            = var.home_region
  vcn_cidrs         = var.vcn_cidrs
  spoke_cidrs       = var.spoke_cidrs
  dns_label         = var.dns_label
  create_nat_gw     = true
  create_svc_gw     = true
  create_inet_gw    = true
  compartments      = module.identity.compartments
}

# ---------- Security (Bastion, NSGs, KMS) ----------
module "security" {
  source                   = "./modules/security"
  compartments             = module.identity.compartments
  network_ids              = module.networking.ids
  enable_bastion_service   = true
  allowed_bastion_cidrs    = var.allowed_bastion_cidrs
  create_vault             = true
  kms_key_alias            = var.kms_key_alias
}

# ---------- Observability (Logging, Events, Budgets) ----------
module "observability" {
  source                 = "./modules/observability"
  compartments           = module.identity.compartments
  budgets                = var.budgets
  enable_audit_log       = true
  log_retention_days     = var.log_retention_days
}

# ---------- OKE-ready (optional) ----------
module "oke_foundation" {
  source                    = "./modules/oke-foundation"
  compartments              = module.identity.compartments
  network_ids               = module.networking.ids
  enable_oke_subnets        = var.enable_oke_foundation
  worker_subnet_cidr        = var.oke_worker_subnet_cidr
  api_endpoint_subnet_cidr  = var.oke_api_endpoint_subnet_cidr
}

output "compartments" {
  value = module.identity.compartments
}

output "network_ids" {
  value = module.networking.ids
}

output "bastion" {
  value = module.security.bastion
}

output "observability" {
  value = module.observability.ids
}

output "oke_foundation" {
  value = module.oke_foundation.ids
}
