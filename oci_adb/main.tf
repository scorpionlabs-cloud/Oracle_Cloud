provider "oci" {
  # Uses ~/.oci/config by default. Override via TF_VAR_... or explicit args.
  # Example:
  # config_file_profile = var.oci_profile
  region = var.region
}

# -----------------------------
# Optional Networking (for private endpoint)
# -----------------------------
locals {
  do_private = var.private_endpoint_enabled
}

resource "oci_core_vcn" "this" {
  count      = local.do_private && var.create_network ? 1 : 0
  cidr_block = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "${var.name_prefix}-vcn"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_internet_gateway" "this" {
  count          = local.do_private && var.create_network ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name_prefix}-igw"
  enabled        = true
}

resource "oci_core_route_table" "public_rt" {
  count          = local.do_private && var.create_network ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name_prefix}-public-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.this[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "adb_private" {
  count                     = local.do_private && var.create_network ? 1 : 0
  compartment_id            = var.compartment_ocid
  vcn_id                    = oci_core_vcn.this[0].id
  display_name              = "${var.name_prefix}-subnet-adb"
  cidr_block                = var.subnet_cidr
  prohibit_public_ip_on_vnic = true
  route_table_id            = oci_core_route_table.public_rt[0].id
  dns_label                 = "adb${random_string.sfx.result}"
  freeform_tags             = var.freeform_tags
}

resource "oci_core_network_security_group" "adb" {
  count          = local.do_private && var.create_network ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name_prefix}-nsg-adb"
  freeform_tags  = var.freeform_tags
}

# Minimal rules (adjust to your environment)
resource "oci_core_network_security_group_security_rule" "egress_all" {
  count                         = local.do_private && var.create_network ? 1 : 0
  network_security_group_id     = oci_core_network_security_group.adb[0].id
  direction                     = "EGRESS"
  protocol                      = "all"
  destination                   = "0.0.0.0/0"
  destination_type              = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "ingress_tls" {
  count                         = local.do_private && var.create_network ? 1 : 0
  network_security_group_id     = oci_core_network_security_group.adb[0].id
  direction                     = "INGRESS"
  protocol                      = "6" # TCP
  source                        = var.private_ingress_cidr
  source_type                   = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
  description = "Allow TLS to ADB private endpoint"
}

resource "random_string" "sfx" {
  length  = 4
  upper   = false
  lower   = true
  special = false
}

# -----------------------------
# Autonomous Database (Serverless)
# -----------------------------
resource "oci_database_autonomous_database" "this" {
  compartment_id = var.compartment_ocid
  db_name        = var.db_name
  display_name   = var.display_name != "" ? var.display_name : var.db_name
  db_workload    = var.db_workload          # "OLTP" or "DW"
  db_version     = var.db_version           # e.g., "19c"
  license_model  = var.license_model        # "LICENSE_INCLUDED" or "BRING_YOUR_OWN_LICENSE"

  # Modern compute settings (ECPU model)
  compute_model  = "ECPU"
  compute_count  = var.compute_count        # e.g., 2, 8, 16 ...

  data_storage_size_in_tbs = var.data_storage_tbs

  is_auto_scaling_enabled = var.autoscaling
  is_free_tier            = var.is_free_tier

  # Admin password (Sensitive)
  admin_password = var.admin_password

  # Access model
  is_access_control_enabled = !var.private_endpoint_enabled
  whitelisted_ips           = var.private_endpoint_enabled ? null : var.whitelisted_ips

  # Private endpoint config
  subnet_id = local.do_private ? coalesce(
    var.subnet_id,
    (length(oci_core_subnet.adb_private) > 0 ? oci_core_subnet.adb_private[0].id : null)
  ) : null

  nsg_ids = local.do_private ? compact([
    var.nsg_id,
    (length(oci_core_network_security_group.adb) > 0 ? oci_core_network_security_group.adb[0].id : null)
  ]) : null

  customer_contacts {
    email = var.notification_email
  }

  # Optional: auto-backup retention
  backup_retention_period_in_days = var.backup_retention_days

  # Optional: character set / ncharset
  # character_set = "AL32UTF8"
  # ncharacter_set = "AL16UTF16"

  freeform_tags = var.freeform_tags
}

# -----------------------------
# Wallet (for SQL*Net / wallet-based connections)
# -----------------------------
resource "oci_database_autonomous_database_wallet" "wallet" {
  autonomous_database_id = oci_database_autonomous_database.this.id
  password               = var.wallet_password
  base64_encode_content  = true
}

# Save wallet zip locally
resource "local_file" "wallet_zip" {
  count    = var.save_wallet_locally ? 1 : 0
  filename = var.wallet_output_path
  content_base64 = oci_database_autonomous_database_wallet.wallet.content
}

# Helpful: show connection strings (JSON)
data "oci_database_autonomous_database" "readback" {
  autonomous_database_id = oci_database_autonomous_database.this.id
}

