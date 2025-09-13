variable "region" {
  description = "OCI region, e.g., ap-singapore-1"
  type        = string
}

variable "compartment_ocid" {
  description = "Target compartment OCID"
  type        = string
}

variable "oci_profile" {
  description = "Profile name in ~/.oci/config (optional)"
  type        = string
  default     = null
}

variable "vcn_cidr" {
  description = "VCN CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.0.10.0/24"
}

variable "ssh_public_key" {
  description = "Your SSH public key (contents of id_rsa.pub or id_ed25519.pub)"
  type        = string
}

variable "instance_display_name" {
  description = "Name for the instance"
  type        = string
  default     = "demo-vm"
}

variable "shape" {
  description = "Compute shape (Flex recommended)"
  type        = string
  default     = "VM.Standard3.Flex"
}

variable "ocpus" {
  description = "OCPUs for Flex shape"
  type        = number
  default     = 2
}

variable "memory_in_gbs" {
  description = "Memory in GB for Flex shape"
  type        = number
  default     = 8
}

variable "assign_public_ip" {
  description = "Assign a public IP to the primary VNIC"
  type        = bool
  default     = true
}

variable "boot_volume_size_gbs" {
  description = "Boot volume size (GB)"
  type        = number
  default     = 50
}

variable "availability_domain_index" {
  description = "0-based index of AD to use"
  type        = number
  default     = 0
}

variable "cloud_init" {
  description = "Optional cloud-init user_data (bash). Will be base64-encoded."
  type        = string
  default     = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - git
      - tmux
      - htop
    runcmd:
      - [ sh, -c, "echo 'Hello from cloud-init' > /etc/motd" ]
  EOT
}

