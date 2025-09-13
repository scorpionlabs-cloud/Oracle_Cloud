variable "tenancy_ocid" {}
variable "region" {}
variable "vcn_cidrs" { type = list(string) }
variable "spoke_cidrs" { type = list(string) }
variable "dns_label" {}
variable "compartments" { type = map(string) }
variable "create_nat_gw" { type = bool, default = true }
variable "create_svc_gw" { type = bool, default = true }
variable "create_inet_gw" { type = bool, default = true }
