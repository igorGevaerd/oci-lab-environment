terraform {
  backend "s3" {
    # OCI Object Storage S3-compatible endpoint
    bucket                      = "terraform-states"
    region                      = "sa-saopaulo-1"
    key                         = "infra/tf.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    use_path_style              = true
    skip_s3_checksum            = true
    skip_metadata_api_check     = true
    endpoints = {
      s3 = "https://grubbyvi3mov.compat.objectstorage.sa-saopaulo-1.oraclecloud.com"
    }
  }
}
