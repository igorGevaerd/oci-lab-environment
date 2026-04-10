terraform {
  required_version = ">= 1.6.4"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Retrieve current compartment data
data "oci_identity_compartment" "root" {
  id = var.tenancy_ocid
}

# Retrieve current region data
data "oci_identity_regions" "current" {
  filter {
    name   = "name"
    values = [var.region]
  }
}
