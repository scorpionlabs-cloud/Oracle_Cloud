How to run

Copy files into adb-terraform folder
cd adb-terraform

# (Optional) Set OCI config/profile env if not using defaults
# export OCI_CLI_PROFILE=DEFAULT

terraform init
terraform plan   -var-file=terraform.tfvars
terraform apply  -var-file=terraform.tfvars


After apply:
- If save_wallet_locally = true, you’ll have a wallet.zip you can use for SQL*Net/Wallet connections.
- Output adb_connection_strings_json includes high, medium, low, all_connection_strings, etc.


Notes:
- Networking choice: Prefer private endpoints for production (no public exposure); attach to a private subnet with egress via NAT or Service Gateway as needed.
- NSG rules: Lock ingress to only the CIDRs and ports required (443 for TCPS).
- Passwords: Consider generating via random_password and store in a secrets vault (e.g., OCI Vault).
- Backups: Adjust backup_retention_period_in_days to match your RPO/RTO.
