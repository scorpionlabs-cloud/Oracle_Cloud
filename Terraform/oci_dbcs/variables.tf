variable "region" {
  description = "OCI region (e.g., ap-singapore-1)"
  type        = string
}

variable "config_file_profile" {
  description = "OCI CLI profile name in ~/.oci/config"
  type        = string
  default     = "DEFAULT"
}

variable "compartment_ocid" {
  description = "Target compartment OCID"
  type        = string
}

variable "availability_domain_index" {
  description = "Index of AD to place DB system (0-based)"
  type        = number
  default     = 0
}

variable "vcn_cidr" {
  description = "VCN CIDR"
  type        = string
  default     = "10.60.0.0/16"
}

variable "subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.60.10.0/24"
}

variable "db_system_display_name" {
  description = "DB system display name"
  type        = string
  default     = "dbcs-system"
}

variable "db_hostname" {
  description = "Hostname (no domain)"
  type        = string
  default     = "dbcs-host"
}

variable "cpu_core_count" {
  description = "OCPU count for VM.Standard3.Flex"
  type        = number
  default     = 2
}

variable "memory_size_in_gbs" {
  description = "Memory (GB) for Flex shapes"
  type        = number
  default     = 32
}

variable "data_storage_size_in_gb" {
  description = "Data storage (GB) for DB system"
  type        = number
  default     = 256
}

variable "database_edition" {
  description = "ENTERPRISE_EDITION, ENTERPRISE_EDITION_EXTREME_PERFORMANCE, etc."
  type        = string
  default     = "ENTERPRISE_EDITION"
}

variable "license_model" {
  description = "LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE"
  type        = string
  default     = "LICENSE_INCLUDED"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
}

variable "db_version" {
  description = "Database version (e.g., 19.22.0.0, 21c if available)"
  type        = string
  default     = "19.22.0.0"
}

variable "db_home_display_name" {
  description = "DB Home display name"
  type        = string
  default     = "dbhome1"
}

variable "db_name" {
  description = "CDB name (8 chars max, starts with letter)"
  type        = string
  default     = "CDB19"
}

variable "pdb_name" {
  description = "PDB name (must start with letter)"
  type        = string
  default     = "PDB1"
}

variable "admin_password" {
  description = "ADMIN password (meets OCI complexity)"
  type        = string
  sensitive   = true
}

variable "nsg_ingress_cidrs" {
  description = "CIDRs allowed to reach DB listener/EM Express (usually bastion/VPN ranges)"
  type        = list(string)
  default     = []
}

variable "dns_label" {
  description = "VCN DNS label"
  type        = string
  default     = "dbvcn"
}

