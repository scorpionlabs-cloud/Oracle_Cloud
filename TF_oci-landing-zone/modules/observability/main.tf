# Audit Log is enabled by default in OCI; create log groups/targets for services
resource "oci_logging_log_group" "lz_logs" {
  compartment_id = var.compartments.platform
  display_name   = "lz-logs"
  description    = "Central log group"
}

# Example service logs (add more per-service as needed)
resource "oci_logging_log" "vcn_flow_logs" {
  compartment_id = var.compartments.network
  display_name   = "vcn-flow-logs"
  log_group_id   = oci_logging_log_group.lz_logs.id
  log_type       = "SERVICE"
  is_enabled     = true
  configuration {
    source {
      category    = "all"
      resource    = "all"
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
  }
  retention_duration = var.log_retention_days
}

# Budgets
resource "oci_budget_budget" "lz_budgets" {
  for_each            = { for b in var.budgets : b.name => b }
  compartment_id      = lookup(var.compartments, each.value.compartment_key, var.compartments.platform)
  amount              = each.value.amount
  display_name        = each.key
  reset_period        = upper(each.value.reset_period)
  description         = "Budget for ${each.value.compartment_key}"
}

output "ids" {
  value = {
    log_group_id = oci_logging_log_group.lz_logs.id
    vcn_flow_log_id = oci_logging_log.vcn_flow_logs.id
    budgets = [for k, v in oci_budget_budget.lz_budgets : v.id]
  }
}
