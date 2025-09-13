resource "oci_core_vcn" "this" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "demo-vcn"
  dns_label      = "demovcn"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "demo-igw"
  enabled        = true
}

resource "oci_core_route_table" "rt_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "rt-public"

  route_rules {
    network_entity_id = oci_core_internet_gateway.igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "sl_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "sl-public"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # SSH
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # ICMP (optional ping)
  ingress_security_rules {
    protocol = "1" # ICMP
    source   = "0.0.0.0/0"
    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_subnet" "public" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.this.id
  cidr_block          = var.public_subnet_cidr
  display_name        = "public-subnet"
  route_table_id      = oci_core_route_table.rt_public.id
  security_list_ids   = [oci_core_security_list.sl_public.id]
  dhcp_options_id     = oci_core_vcn.this.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false
  dns_label           = "pubsub"
}

