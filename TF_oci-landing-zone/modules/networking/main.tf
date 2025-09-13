# Hub VCN
resource "oci_core_vcn" "hub" {
  cidr_block   = var.vcn_cidrs[0]
  compartment_id = var.compartments.network
  display_name = "hub-vcn"
  dns_label    = var.dns_label
}

resource "oci_core_internet_gateway" "igw" {
  count          = var.create_inet_gw ? 1 : 0
  compartment_id = var.compartments.network
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "hub-igw"
  is_enabled     = true
}

resource "oci_core_nat_gateway" "nat" {
  count          = var.create_nat_gw ? 1 : 0
  compartment_id = var.compartments.network
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "hub-nat"
}

resource "oci_core_service_gateway" "sgw" {
  count          = var.create_svc_gw ? 1 : 0
  compartment_id = var.compartments.network
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "hub-svcgw"
  services = [for svc in data.oci_core_services.all.services : svc.id if contains(svc.cidr_block, "all-oci-services-in-oracle-services-network")]
}
data "oci_core_services" "all" {}

# DRG + Attachment (for future hybrid connectivity)
resource "oci_core_drg" "drg" {
  compartment_id = var.compartments.network
  display_name   = "hub-drg"
}
resource "oci_core_drg_attachment" "drg_hub_attach" {
  drg_id = oci_core_drg.drg.id
  vcn_id = oci_core_vcn.hub.id
  display_name = "hub-drg-attach"
}

# Hub subnets (public + private)
resource "oci_core_subnet" "hub_public" {
  compartment_id = var.compartments.network
  vcn_id         = oci_core_vcn.hub.id
  cidr_block     = cidrsubnet(oci_core_vcn.hub.cidr_block, 8, 1)
  display_name   = "hub-public"
  prohibit_public_ip_on_vnic = false
  route_table_id = oci_core_route_table.hub_public.id
  dns_label      = "hubpub"
}
resource "oci_core_subnet" "hub_private" {
  compartment_id = var.compartments.network
  vcn_id         = oci_core_vcn.hub.id
  cidr_block     = cidrsubnet(oci_core_vcn.hub.cidr_block, 8, 2)
  display_name   = "hub-private"
  prohibit_public_ip_on_vnic = true
  route_table_id = oci_core_route_table.hub_private.id
  dns_label      = "hubpri"
}

# Route tables
resource "oci_core_route_table" "hub_public" {
  compartment_id = var.compartments.network
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "rtb-hub-public"
  route_rules = [
    for gw in [one(oci_core_internet_gateway.igw).*] : {
      cidr_block = "0.0.0.0/0"
      network_entity_id = length(oci_core_internet_gateway.igw) > 0 ? oci_core_internet_gateway.igw[0].id : null
      description = "To Internet"
    }
  ]
}

resource "oci_core_route_table" "hub_private" {
  compartment_id = var.compartments.network
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "rtb-hub-private"
  route_rules = [
    for gw in [one(oci_core_nat_gateway.nat).*] : {
      cidr_block = "0.0.0.0/0"
      network_entity_id = length(oci_core_nat_gateway.nat) > 0 ? oci_core_nat_gateway.nat[0].id : null
      description = "To NAT"
    }
  ]
}

# Spoke VCNs (loop)
resource "oci_core_vcn" "spoke" {
  for_each       = toset(var.spoke_cidrs)
  compartment_id = var.compartments.network
  cidr_block     = each.value
  display_name   = "spoke-${replace(each.value, "/", "_")}"
  dns_label      = "sp${substr(replace(each.value,".",""),0,8)}"
}

# Basic output IDs
output "ids" {
  value = {
    hub_vcn_id       = oci_core_vcn.hub.id
    hub_public_subnet  = oci_core_subnet.hub_public.id
    hub_private_subnet = oci_core_subnet.hub_private.id
    drg_id           = oci_core_drg.drg.id
    spoke_vcns       = { for k, v in oci_core_vcn.spoke : k => v.id }
  }
}
