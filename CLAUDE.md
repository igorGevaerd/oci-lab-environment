# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Terraform configuration project for Oracle Cloud Infrastructure (OCI) that manages a lab environment. The project uses Terraform to define cloud infrastructure as code.

## Common Development Commands

All commands should be run from the `terraform/infra` directory.

### Terraform Initialization
```bash
cd terraform/infra
terraform init
```
Initializes the Terraform working directory, downloads required providers and modules.

### Validating Configuration
```bash
cd terraform/infra
terraform validate
```
Syntax checks the Terraform configuration files without requiring providers or credentials.

### Formatting Code
```bash
cd terraform/infra
terraform fmt -recursive
```
Automatically formats all Terraform files to canonical style. Use this before committing.

### Planning Changes
```bash
cd terraform/infra
terraform plan -out=tfplan
```
Creates an execution plan showing what will be created, modified, or destroyed. Review this carefully before applying.

### Applying Configuration
```bash
cd terraform/infra
terraform apply tfplan
```
Applies the changes defined in the plan. Always review the plan before running apply.

### Viewing State
```bash
cd terraform/infra
terraform state list
```
Lists all resources managed by the current state file.

```bash
cd terraform/infra
terraform state show <resource_name>
```
Shows detailed information about a specific resource.

### Destroying Infrastructure
```bash
cd terraform/infra
terraform destroy
```
Destroys all resources defined in the Terraform configuration. Use with caution in production.

## Project Structure

Expected directory layout:
```
terraform/
├── infra/                      # OCI infrastructure resources
│   ├── main.tf                 # Primary resource definitions
│   ├── variables.tf            # Variable declarations and defaults
│   ├── outputs.tf              # Output values exposed by the configuration
│   ├── provider.tf             # OCI provider configuration
│   ├── backend.tf              # Remote state configuration
│   ├── terraform.tfvars        # Variable values (NOT committed, in .gitignore)
│   ├── terraform.tfvars.example # Template for variable values
│   ├── modules/
│   │   └── kubernetes/         # Kubernetes cluster module
│   └── .terraform/             # Provider plugins and modules (NOT committed)
└── environments/               # Environment-specific configurations
    └── dev/
```

Key files to ignore (in .gitignore):
- `terraform.tfvars` - Sensitive variable values
- `.terraform/` - Provider plugins and modules
- `*.tfstate` - State files
- `*.tfstate.*` - State backups

## Key Concepts

### State Management
- Terraform state files (`.tfstate`) track the actual infrastructure and should **never** be committed
- For collaborative work, use remote state (e.g., OCI Object Storage, Terraform Cloud)
- State is sensitive and may contain secrets - handle carefully

### Variables and Secrets
- Use `terraform.tfvars` for environment-specific values (NOT committed)
- Create `terraform.tfvars.example` to show what variables are needed
- Use `sensitive = true` on variable declarations for passwords, API keys, etc.
- Never hardcode secrets in `.tf` files

### Variable Files
- Can pass multiple variable files (from `terraform/infra` directory): `terraform plan -var-file="prod.tfvars"`
- `-var` flag can override specific variables: `terraform plan -var="environment=prod"`
- Always run Terraform commands from the `terraform/infra` directory

## OCI-Specific Guidance

### Provider Configuration
The OCI provider should be configured with:
- `tenancy_ocid` - Oracle Cloud Tenancy ID
- `user_ocid` - User OCID
- `fingerprint` - API key fingerprint
- `private_key_path` - Path to private key file
- `region` - OCI region (e.g., `us-phoenix-1`)

### Common OCI Resources
- `oci_core_instance` - Compute instances (VMs)
- `oci_core_vcn` - Virtual Cloud Networks
- `oci_core_subnet` - Subnets
- `oci_core_internet_gateway` - Internet Gateways
- `oci_core_security_list` - Security rules

## Best Practices

1. **Always run `terraform fmt` before committing** to maintain consistent formatting
2. **Review `terraform plan` output carefully** before applying - it shows exactly what will change
3. **Use descriptive resource names** that indicate purpose and environment
4. **Organize resources logically** - group related resources together in files
5. **Use variables and outputs** to avoid hardcoding values and enable reusability
6. **Use `for_each` or `count`** instead of copying resource blocks when creating multiple similar resources
7. **Tag resources appropriately** for cost tracking and organization
8. **Test in dev/lab environment first** before applying to production

## Git Workflow

This project follows the standard git workflow:
- Create feature branches for changes: `git checkout -b feat/add-compute-instances`
- Run `terraform validate` and `terraform fmt` before committing (from `terraform/infra` directory)
- Create pull requests for code review
- Do not commit `.tfstate`, `.tfstate.*`, `.terraform/`, or `.tfvars` files (these are in `.gitignore`)
- Terraform files are located in `terraform/infra/` subdirectory

## Terraform Backend Configuration

To switch to remote state management using OCI Object Storage, create a `terraform/infra/backend.tf` file (requires Terraform >= 1.6.4):
```hcl
terraform {
  backend "s3" {
    bucket                      = "terraform-states"
    region                      = "sa-saopaulo-1"
    key                         = "tf.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    use_path_style              = true
    skip_s3_checksum            = true
    skip_metadata_api_check     = true
    endpoints = {
      s3 = "https://<namespace>.compat.objectstorage.sa-saopaulo-1.oraclecloud.com"
    }
  }
}
```

**Configuration notes:**
- Replace `<namespace>` with your OCI Object Storage namespace
- The S3-compatible endpoint allows OCI Object Storage to work with Terraform's S3 backend
- Ensure OCI credentials are configured via environment variables or API key authentication
- Region is set to `sa-saopaulo-1` (your home region) - do not change

## Debugging and Troubleshooting

Enable debug logging:
```bash
TF_LOG=DEBUG terraform plan
```

Common issues:
- **Authentication errors**: Verify OCI credentials and API key fingerprint
- **Resource conflicts**: Check if resources already exist in OCI
- **State mismatch**: Use `terraform refresh` to sync state with actual infrastructure
- **Provider errors**: Run `terraform init` to ensure providers are up to date
