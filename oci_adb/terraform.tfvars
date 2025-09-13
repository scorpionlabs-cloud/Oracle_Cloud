region            = "ap-singapore-1"
compartment_ocid  = "ocid1.compartment.oc1..aaaa...yourcompartment"

db_name           = "MYADB01"
display_name      = "my-adb-prod"
db_workload       = "OLTP"      # or "DW"
db_version        = "19c"
license_model     = "LICENSE_INCLUDED"

compute_count     = 8
data_storage_tbs  = 1
autoscaling       = true
is_free_tier      = false

admin_password    = "Strong_Pa55word#123"    # change me
wallet_password   = "Another_Strong#123"     # change me

# Public ADB example:
private_endpoint_enabled = false
whitelisted_ips          = ["203.0.113.10/32", "198.51.100.0/24"]  # tighten!

# OR Private endpoint example:
# private_endpoint_enabled = true
# create_network           = true
# vcn_cidr                 = "10.60.0.0/16"
# subnet_cidr              = "10.60.10.0/24"
# private_ingress_cidr     = "10.60.0.0/16"

freeform_tags = {
  env        = "prod"
  app        = "payments"
  managed-by = "terraform"
}

