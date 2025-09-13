output "instance_id" {
  value = oci_core_instance.vm.id
}

output "public_ip" {
  value       = try(oci_core_instance.vm.public_ip, null)
  description = "Null if assign_public_ip=false"
}

output "private_ip" {
  value = oci_core_instance.vm.private_ip
}

output "ssh_command" {
  value       = var.assign_public_ip ? "ssh opc@${oci_core_instance.vm.public_ip}" : "No public IP assigned"
  description = "Use this to connect (ensure your private key is loaded)"
}

