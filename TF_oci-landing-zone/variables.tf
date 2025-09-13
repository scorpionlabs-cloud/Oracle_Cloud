##############################
# Global Inputs
##############################
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" { default = "~/.oci/oci_api_key.pem" }
variable "home_region" { description = "Your home region (e.g. ap-singapore-1)" }

variable "landing_zone_name" {
  description = "Prefix for resources"
  default     = "lz"
}

# Identity
variable "iam_admin_group_name" {
  description = "Name for the IAM Admin group to manage the landing zone"
  default     = "lz-admins"
}
variable "enable_security_zones" { type = bool, default = true }
variable "enable_cloud_guard"   { type = bool, default = true }

# Networking
variable "vcn_cidrs" {
  description = "CIDR blocks for hub VCN (one or more)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
variable "spoke_cidrs" {
  description = "List of spoke VCN CIDRs (spokes auto-created)"
  type        = list(string)
  default     = ["10.10.0.0/16", "10.20.0.0/16"]
}
variable "dns_label" { default = "lz" }

# Security
variable "allowed_bastion_cidrs" {
  description = "CIDRs allowed to connect to Bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "kms_key_alias" { default = "lz-master-key" }

# Observability
variable "budgets" {
  description = "Budgets to create per compartment (list of objects)"
  type = list(object({
    name             = string
    amount           = number
    reset_period     = string # MONTHLY
    compartment_key  = string # e.g., "shared", "network", "platform", "dev", "prod"
  }))
  default = []
}
variable "log_retention_days" { default = 90 }

# OKE Foundation
variable "enable_oke_foundation"       { type = bool, default = true }
variable "oke_worker_subnet_cidr"      { default = "10.10.10.0/24" }
variable "oke_api_endpoint_subnet_cidr"{ default = "10.10.20.0/28" }
