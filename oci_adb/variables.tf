variable "region" {
  description = "OCI region (e.g., ap-singapore-1)"
  type        = string
}

variable "compartment_ocid" {
  description = "Target compartment OCID"
  type        = string
}

variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "adb"
}

variable "db_name" {
  description = "ADB DB name (8–14 chars, alphanum)"
  type        = string
}

variable "display_name" {
  description = "Friendly display name"
  type        = string
  default     = ""
}

variable "db_workload" {
  description = "OLTP or DW"
  type        = string
  default     = "OLTP"
  validation {
    condition     = contains(["OLTP", "DW"], var.db_workload)
    error_message = "db_workload must be OLTP or DW."
  }
}

variable "db_version" {
  description = "ADB version (e.g., 19c)"
  type        = string
  default     = "19c"
}

variable "license_model" {
  description = "LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE"
  type        = string
  default     = "LICENSE_INCLUDED"
}

variable "compute_count" {
  description = "ECPU count for ADB"
  type        = number
  default     = 8
}

variable "data_storage_tbs" {
  description = "Storage size in TBs"
  type        = number
  default     = 1
}

variable "autoscaling" {
  description = "Enable auto-scaling"
  type        = bool
  default     = true
}

variable "is_free_tier" {
  description = "Use Always Free tier if available"
  type        = bool
  default     = false
}

variable "admin_password" {
  description = "ADB ADMIN password"
  type        = string
  sensitive   = true
}

# ---------- Access Model ----------
variable "private_endpoint_enabled" {
  description = "Create a private endpoint inside a subnet"
  type        = bool
  default     = false
}

variable "whitelisted_ips" {
  description = "Allowed public IP CIDRs (for public ADB)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # tighten for production
}

# ---------- Networking (for private endpoint) ----------
variable "create_network" {
  description = "Create VCN and Subnet for private endpoint"
  type        = bool
  default     = true
}

variable "vcn_cidr" {
  description = "VCN CIDR"
  type        = string
  default     = "10.60.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.60.10.0/24"
}

variable "subnet_id" {
  description = "Use existing subnet OCID (overrides create_network)"
  type        = string
  default     = null
}

variable "nsg_id" {
  description = "Existing NSG OCID (optional)"
  type        = string
  default     = null
}

variable "private_ingress_cidr" {
  description = "Ingress CIDR to reach ADB private endpoint on 443"
  type        = string
  default     = "10.0.0.0/8"
}

# ---------- Wallet ----------
variable "wallet_password" {
  description = "Wallet zip password"
  type        = string
  sensitive   = true
}

variable "save_wallet_locally" {
  description = "Save wallet zip to local file"
  type        = bool
  default     = true
}

variable "wallet_output_path" {
  description = "Local path for wallet zip"
  type        = string
  default     = "./wallet.zip"
}

# ---------- Notifications & Tags ----------
variable "notification_email" {
  description = "Optional contact email for ADB"
  type        = string
  default     = ""
}

variable "freeform_tags" {
  description = "Tags map"
  type        = map(string)
  default     = {
    "managed-by" = "terraform"
  }
}

# Optional: oci profile (uncomment provider config to use)
# variable "oci_profile" {
#   description = "Profile in ~/.oci/config"
#   type        = string
#   default     = "DEFAULT"
# }

