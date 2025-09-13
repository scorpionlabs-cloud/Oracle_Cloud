variable "compartments" { type = map(string) }
variable "budgets" {
  type = list(object({
    name             = string
    amount           = number
    reset_period     = string
    compartment_key  = string
  }))
  default = []
}
variable "enable_audit_log" { type = bool, default = true }
variable "log_retention_days" { default = 90 }
