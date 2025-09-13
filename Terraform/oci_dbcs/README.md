How to use

# 1) Save files in a folder, then:
- terraform init

# 2) Review and adjust variables in terraform.tfvars
#    Ensure your ~/.oci/config has the chosen profile.

# 3) Plan and apply
- terraform plan
- terraform apply

Notes:
- Private subnet only: DB node gets no public IP. Access it via bastion/VPN. Adjust nsg_ingress_cidrs to your secure CIDRs.
- Shape: Change shape, cpu_core_count, and memory_size_in_gbs as needed (Flex shapes require both CPU & memory).
- Edition/License: Set database_edition and license_model per your entitlement.
- Patching/Maintenance: For controlled windows, set maintenance_window_details.preference = "CUSTOM_PREFERENCE" and specify day/hour.
- Data Guard: If you want a standby, add a oci_database_data_guard_association resource after the primary is up (can share a template if you need it).
- Backups: You can configure automatic backups on the DB system (let me know if you want a backup policy block included).
