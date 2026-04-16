output "region" {
  description = "OCI Region"
  value       = var.region
}

output "compartment_ocid" {
  description = "Compartment OCID"
  value       = data.oci_identity_compartment.root.id
  sensitive   = true
}

output "tenancy_ocid" {
  description = "Tenancy OCID"
  value       = var.tenancy_ocid
  sensitive   = true
}
