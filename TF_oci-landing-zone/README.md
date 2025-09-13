# OCI Landing Zone — Terraform

This is a **production-grade OCI landing zone** with modular Terraform.
It focuses on: **multi-compartment IAM**, **hub-spoke networking**, **security guardrails (Cloud Guard + Security Zones)**,
**centralised logging**, **budgets/quotas**, **OKE-ready subnets**, and **bastion access**.

cd oci-landing-zone
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your tenancy/user OCIDs, region, CIDRs, etc.

terraform init
terraform plan
terraform apply
