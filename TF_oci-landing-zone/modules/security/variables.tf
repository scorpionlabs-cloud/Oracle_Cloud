variable "compartments" { type = map(string) }
variable "network_ids"  { type = map(any) }
variable "enable_bastion_service" { type = bool, default = true }
variable "allowed_bastion_cidrs" { type = list(string) }
variable "create_vault" { type = bool, default = true }
variable "kms_key_alias" {}
