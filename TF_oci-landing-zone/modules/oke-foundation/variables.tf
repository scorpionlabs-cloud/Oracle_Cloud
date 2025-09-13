variable "compartments" { type = map(string) }
variable "network_ids"  { type = map(any) }
variable "enable_oke_subnets" { type = bool, default = true }
variable "worker_subnet_cidr" {}
variable "api_endpoint_subnet_cidr" {}
