# Bastion
resource "oci_bastion_bastion" "bastion" {
  count = var.enable_bastion_service ? 1 : 0
  compartment_id = var.compartments.shared
  name           = "lz-bastion"
  bastion_type   = "STANDARD"
  target_subnet_id = var.network_ids["hub_public_subnet"]
  client_cidr_block_allow_list = var.allowed_bastion_cidrs
}

# Vault + Master Key
resource "oci_kms_vault" "lz_vault" {
  count          = var.create_vault ? 1 : 0
  compartment_id = var.compartments.platform
  display_name   = "lz-vault"
  vault_type     = "DEFAULT"
}

data "oci_kms_vault" "vault_data" {
  count = var.create_vault ? 1 : 0
  vault_id = oci_kms_vault.lz_vault[0].id
}

resource "oci_kms_key" "master_kek" {
  count = var.create_vault ? 1 : 0
  compartment_id = var.compartments.platform
  display_name   = var.kms_key_alias
  management_endpoint = data.oci_kms_vault.vault_data[0].management_endpoint
  key_shape {
    algorithm = "AES"
    length    = 32
  }
  protection_mode = "HSM"
}

output "bastion" {
  value = {
    id = length(oci_bastion_bastion.bastion) > 0 ? oci_bastion_bastion.bastion[0].id : null
  }
}
