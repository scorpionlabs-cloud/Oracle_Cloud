terraform {
  required_version = ">= 1.6.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}

