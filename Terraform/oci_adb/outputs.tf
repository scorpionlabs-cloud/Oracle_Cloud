output "adb_id" {
  value       = oci_database_autonomous_database.this.id
  description = "Autonomous Database OCID"
}

output "adb_private_endpoint" {
  value       = try(data.oci_database_autonomous_database.readback.private_endpoint, null)
  description = "Private endpoint (if enabled)"
}

output "adb_connection_strings_json" {
  value       = jsonencode(try(data.oci_database_autonomous_database.readback.connection_strings, {}))
  description = "Connection strings JSON"
  sensitive   = true
}

output "wallet_file" {
  value       = var.save_wallet_locally ? var.wallet_output_path : null
  description = "Local wallet zip file (if saved)"
}

output "adb_console_url" {
  value       = "https://cloud.oracle.com/database/autonomous-database/${oci_database_autonomous_database.this.id}?region=${var.region}"
  description = "Convenience link to ADB in OCI Console"
}

