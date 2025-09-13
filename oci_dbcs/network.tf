data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr
  display_name   = "dbcs-vcn"
  dns_label      = var.dns_label
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "igw"
  enabled        = true
}

resource "oci_core_route_table" "rt_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "rt-public"

  route_rules {
    network_entity_id = oci_core_internet_gateway.igw.id
    destination       = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "db_subnet" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.this.id
  cidr_block          = var.subnet_cidr
  display_name        = "db-subnet"
  prohibit_public_ip_on_vnic = true
  route_table_id      = oci_core_route_table.rt_public.id
  dns_label           = "dbsubnet"
}

# Network Security Groups (recommended over security lists)
resource "oci_core_network_security_group" "db_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "db-nsg"
}

# Listener (1521) + EM Express (5500) inbound from approved CIDRs
resource "oci_core_network_security_group_security_rule" "ingress_1521" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  source                    = length(var.nsg_ingress_cidrs) > 0 ? var.nsg_ingress_cidrs[0] : "10.0.0.0/8"

  tcp_options {
    destination_port_range {
      min = 1521
      max = 1521
    }
  }
  description = "Allow SQL*Net"
}

resource "oci_core_network_security_group_security_rule" "ingress_5500" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source_type               = "CIDR_BLOCK"
  source                    = length(var.nsg_ingress_cidrs) > 1 ? var.nsg_ingress_cidrs[1] : "10.0.0.0/8"

  tcp_options {
    destination_port_range {
      min = 5500
      max = 5500
    }
  }
  description = "Allow EM Express"
}

# Egress anywhere
resource "oci_core_network_security_group_security_rule" "egress_all" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  description               = "Allow all egress"
}

