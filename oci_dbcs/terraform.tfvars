region               = "ap-singapore-1"
config_file_profile  = "DEFAULT"
compartment_ocid     = "ocid1.compartment.oc1..aaaa...yourcompartment"

ssh_public_key_path  = "~/.ssh/id_rsa.pub"

# Networking
vcn_cidr    = "10.60.0.0/16"
subnet_cidr = "10.60.10.0/24"

# DB sizing
cpu_core_count          = 2
memory_size_in_gbs      = 32
data_storage_size_in_gb = 512

# DB options
database_edition = "ENTERPRISE_EDITION"
license_model    = "LICENSE_INCLUDED"
db_version       = "19.22.0.0"

db_system_display_name = "dbcs-system"
db_home_display_name   = "dbhome1"
db_hostname            = "dbcs-host"
db_name                = "CDB19"
pdb_name               = "PDB1"

# Must meet OCI complexity rules (12–30 chars, uppercase, lowercase, number, special)
admin_password = "Str0ng!Passw0rd123"
# Allow from your bastion/VPN ranges if needed
nsg_ingress_cidrs = ["10.0.0.0/8", "10.0.0.0/8"]

