variable "tenancy_ocid" {
  description = "Oracle Cloud Tenancy OCID"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "Oracle Cloud User OCID"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "Fingerprint of OCI user API key"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to OCI user API key (private key file)"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "OCI Region (must be home region for free tier)"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "namespace" {
  description = "OCI Object Storage namespace"
  type        = string
  sensitive   = true
}

variable "compartment_name" {
  description = "OCI Compartment name for resources"
  type        = string
  default     = "Default"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "oci-k8s-lab"
}
