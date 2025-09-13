How to use

1. Install Terraform and the OCI CLI

2. Prepare keys (if you don’t already have one):
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "$(whoami)@$(hostname)"

3. Then copy the contents of ~/.ssh/id_ed25519.pub into ssh_public_key in your terraform.tfvars

4. Initialize & apply
terraform init
cp terraform.tfvars.example terraform.tfvars   # edit values
terraform plan
terraform apply -auto-approve

5. Connect
ssh opc@$(terraform output -raw public_ip)

Notes:
- No Public IP? set assign_public_ip = false for private-only; reach it via Bastion or VPN.
- Different OS: change the data "oci_core_images" filter (e.g., Oracle Linux 9).
