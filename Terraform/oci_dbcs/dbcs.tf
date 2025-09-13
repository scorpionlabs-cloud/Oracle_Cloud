# DB System (DBCS VM)
resource "oci_database_db_system" "dbcs" {
  availability_domain   = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_index].name
  compartment_id        = var.compartment_ocid
  subnet_id             = oci_core_subnet.db_subnet.id

  display_name          = var.db_system_display_name
  hostname              = var.db_hostname

  shape                 = "VM.Standard3.Flex"
  cpu_core_count        = var.cpu_core_count
  memory_size_in_gbs    = var.memory_size_in_gbs

  data_storage_size_in_gb = var.data_storage_size_in_gb
  database_edition        = var.database_edition
  license_model           = var.license_model
  node_count              = 1
  disk_redundancy         = "AUTO"

  ssh_public_keys = [
    file(var.ssh_public_key_path)
  ]

  nsg_ids = [
    oci_core_network_security_group.db_nsg.id
  ]

  db_system_options {
    storage_management = "LVM"
  }

  # Maintenance
  maintenance_window_details {
    preference = "NO_PREFERENCE"
  }

  # Timezone (optional)
  time_zone = "UTC"
}

# Create DB Home + CDB/PDB (inline ‘database’ block is supported)
resource "oci_database_db_home" "dbhome" {
  db_system_id = oci_database_db_system.dbcs.id
  display_name = var.db_home_display_name
  db_version   = var.db_version

  database {
    db_name             = var.db_name
    admin_password      = var.admin_password
    character_set       = "AL32UTF8"
    nchar_character_set = "AL16UTF16"
    db_workload         = "OLTP"
    pdb_name            = var.pdb_name
  }
}

