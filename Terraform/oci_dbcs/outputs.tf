output "db_system_id" {
  value = oci_database_db_system.dbcs.id
}

output "db_home_id" {
  value = oci_database_db_home.dbhome.id
}

output "db_private_ips" {
  description = "Private IPs of DB nodes"
  value       = oci_database_db_system.dbcs.private_ips
}

output "listener_connect_string" {
  description = "EZCONNECT style (host:1521/PDB)"
  value       = "${oci_database_db_system.dbcs.hostname}:1521/${var.pdb_name}"
}

