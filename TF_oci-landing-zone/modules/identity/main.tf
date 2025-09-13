locals {
  # canonical set of compartments
  compartments = {
    root     = var.tenancy_ocid
    shared   = null
    network  = null
    platform = null
    dev      = null
    prod     = null
  }
}

# Compartments
resource "oci_identity_compartment" "shared" {
  compartment_id = var.tenancy_ocid
  name           = "${var.landing_zone_name}-shared"
  description    = "Shared services"
  enable_delete  = true
}
resource "oci_identity_compartment" "network" {
  compartment_id = var.tenancy_ocid
  name           = "${var.landing_zone_name}-network"
  description    = "Networking hub/spokes"
  enable_delete  = true
}
resource "oci_identity_compartment" "platform" {
  compartment_id = var.tenancy_ocid
  name           = "${var.landing_zone_name}-platform"
  description    = "Platform and security services"
  enable_delete  = true
}
resource "oci_identity_compartment" "dev" {
  compartment_id = var.tenancy_ocid
  name           = "${var.landing_zone_name}-dev"
  description    = "Development workloads"
  enable_delete  = true
}
resource "oci_identity_compartment" "prod" {
  compartment_id = var.tenancy_ocid
  name           = "${var.landing_zone_name}-prod"
  description    = "Production workloads"
  enable_delete  = true
}

# IAM Admin Group (create if not exists via resource)
resource "oci_identity_group" "lz_admins" {
  compartment_id = var.tenancy_ocid
  name           = var.iam_admin_group_name
  description    = "Landing Zone Admins"
}

# Example Policies (tighten per org)
resource "oci_identity_policy" "lz_admins_policy" {
  compartment_id = var.tenancy_ocid
  name           = "${var.landing_zone_name}-admins-policy"
  description    = "Allow LZ Admins to manage core resources in LZ compartments"
  statements = [
    "Allow group ${oci_identity_group.lz_admins.name} to manage all-resources in compartment ${oci_identity_compartment.shared.name}",
    "Allow group ${oci_identity_group.lz_admins.name} to manage all-resources in compartment ${oci_identity_compartment.network.name}",
    "Allow group ${oci_identity_group.lz_admins.name} to manage all-resources in compartment ${oci_identity_compartment.platform.name}",
    "Allow group ${oci_identity_group.lz_admins.name} to manage all-resources in compartment ${oci_identity_compartment.dev.name}",
    "Allow group ${oci_identity_group.lz_admins.name} to manage all-resources in compartment ${oci_identity_compartment.prod.name}",
    "Allow group ${oci_identity_group.lz_admins.name} to read tenancy usage-report in tenancy",
  ]
  description_details = {}
}

# (Optional) Security Zones + Cloud Guard (control-plane guardrails)
resource "oci_cloud_guard_configuration" "org" {
  # Cloud Guard must be enabled at tenancy level; region-scoped
  # Enable only if requested; default is true
  count = var.enable_cloud_guard ? 1 : 0
  compartment_id = var.tenancy_ocid
  reporting_region = var.home_region
  status = "ENABLED"
}

# Output compartment OCIDs as a map
output "compartments" {
  value = {
    root     = var.tenancy_ocid
    shared   = oci_identity_compartment.shared.id
    network  = oci_identity_compartment.network.id
    platform = oci_identity_compartment.platform.id
    dev      = oci_identity_compartment.dev.id
    prod     = oci_identity_compartment.prod.id
  }
}
