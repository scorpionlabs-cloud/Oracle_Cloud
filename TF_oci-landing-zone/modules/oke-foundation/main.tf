# Create OKE-ready subnets + NSGs (no cluster here; just infra)
resource "oci_core_subnet" "oke_workers" {
  count               = var.enable_oke_subnets ? 1 : 0
  compartment_id      = var.compartments.network
  vcn_id              = var.network_ids["hub_vcn_id"]
  cidr_block          = var.worker_subnet_cidr
  display_name        = "oke-workers"
  prohibit_public_ip_on_vnic = true
  route_table_id      = null
  dns_label           = "okewrk"
}

resource "oci_core_subnet" "oke_api" {
  count               = var.enable_oke_subnets ? 1 : 0
  compartment_id      = var.compartments.network
  vcn_id              = var.network_ids["hub_vcn_id"]
  cidr_block          = var.api_endpoint_subnet_cidr
  display_name        = "oke-api-endpoint"
  prohibit_public_ip_on_vnic = false
  route_table_id      = null
  dns_label           = "okeapi"
}

# Minimal NSGs (tighten in real deployments)
resource "oci_core_network_security_group" "oke_nsg" {
  count               = var.enable_oke_subnets ? 1 : 0
  compartment_id      = var.compartments.network
  vcn_id              = var.network_ids["hub_vcn_id"]
  display_name        = "oke-nsg"
}

output "ids" {
  value = {
    worker_subnet_id = length(oci_core_subnet.oke_workers) > 0 ? oci_core_subnet.oke_workers[0].id : null
    api_subnet_id    = length(oci_core_subnet.oke_api) > 0 ? oci_core_subnet.oke_api[0].id : null
    nsg_id           = length(oci_core_network_security_group.oke_nsg) > 0 ? oci_core_network_security_group.oke_nsg[0].id : null
  }
}
