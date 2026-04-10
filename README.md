# OCI Kubernetes Lab Environment

A Terraform-based infrastructure-as-code project for deploying a Kubernetes cluster on Oracle Cloud Infrastructure (OCI) Free Tier in São Paulo, Brazil.

## 📋 Project Overview

This project deploys and manages OCI resources using Terraform with:
- **Infrastructure as Code**: Everything defined in Terraform
- **Remote State Management**: State stored in OCI Object Storage S3-compatible bucket
- **Development Environment**: Terraform workspace for dev environment
- **Free Tier**: All resources within OCI Always Free tier limits
- **Brazilian Region**: Located in `sa-saopaulo-1` (São Paulo)

## 🏗️ Project Structure

```
.
├── terraform/
│   └── infra/                           # OCI infrastructure resources
│       ├── main.tf                      # Primary resource definitions
│       ├── variables.tf                 # Variable declarations
│       ├── outputs.tf                   # Output values
│       ├── provider.tf                  # OCI provider configuration
│       ├── backend.tf                   # Remote S3 backend configuration
│       ├── terraform.tfvars             # Your credentials (NOT committed)
│       ├── terraform.tfvars.example     # Template for tfvars
│       ├── .terraform/                  # Provider plugins (ignored)
│       ├── .terraform.lock.hcl          # Provider version lock
│       └── scripts/
│           └── setup-tfvars.sh          # Auto-generate terraform.tfvars
├── docs/
│   └── internal/
│       ├── SETUP-GUIDE.md               # Comprehensive setup instructions
│       ├── region-selection-notes.md    # Region selection rationale
│       └── (other internal docs)
├── CLAUDE.md                            # Claude Code guidance
├── README.md                            # This file
└── .gitignore                           # Git ignore rules

```

## 🚀 Quick Start

### Prerequisites

- OCI Free Tier account (with sa-saopaulo-1 as home region)
- [Terraform](https://www.terraform.io/downloads.html) >= 1.6.4
- [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/climanualinstall.htm) configured
- [AWS CLI](https://aws.amazon.com/cli/) v2.23.5+ (for S3-compatible Object Storage)

### Setup in 5 Minutes

1. **Generate terraform.tfvars from OCI config**:
```bash
cd terraform/infra/scripts
bash setup-tfvars.sh
cd ..
```

2. **Add AWS credentials to ~/.zshrc**:
```bash
# Go to OCI Console → Profile → Customer Secret Keys → Generate
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REQUEST_CHECKSUM_CALCULATION="when_required"
export AWS_RESPONSE_CHECKSUM_VALIDATION="when_required"

source ~/.zshrc
```

3. **Create Object Storage bucket** (manual, one-time):
```bash
# OCI Console → Object Storage → Buckets
# - Name: terraform-states
# - Enable Versioning
```

4. **Initialize Terraform**:
```bash
cd terraform/infra
terraform init
terraform plan
```

5. **Create dev workspace**:
```bash
terraform workspace new dev
terraform workspace select dev
```

## 📚 Documentation

- **[CLAUDE.md](./CLAUDE.md)** - Project guidelines, Terraform commands, and best practices for Claude Code integration

## 🔐 Security

### Sensitive Files (Ignored)
- `terraform.tfvars` - Contains OCI credentials
- `.terraform/` - Downloaded provider plugins
- `*.tfstate*` - Infrastructure state (stored in remote bucket)
- `.terraform.lock.hcl` - Lock info

**Never commit**:
- API keys or credentials
- Private keys
- State files

### Environment Variables Required

All Terraform commands require these environment variables:

```bash
# OCI Provider (from ~/.oci/config)
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..xxxxx"
export TF_VAR_user_ocid="ocid1.user.oc1..xxxxx"
export TF_VAR_fingerprint="xx:xx:xx:xx:xx:xx"
export TF_VAR_private_key_path="~/.oci/oci_api_key.pem"

# AWS S3 Backend (OCI Object Storage)
export AWS_ACCESS_KEY_ID="your-customer-secret-key-id"
export AWS_SECRET_ACCESS_KEY="your-customer-secret-key"
export AWS_REQUEST_CHECKSUM_CALCULATION="when_required"
export AWS_RESPONSE_CHECKSUM_VALIDATION="when_required"
```

## 📊 Free Tier Resources

All resources are within OCI Always Free tier limits:

| Resource | Limit | Usage |
|---|---|---|
| **Compute** | 4 OCPU + 24GB RAM | 2x VM.Standard.A1.Flex instances |
| **Object Storage** | 20GB | Terraform state + backups |
| **Block Storage** | 200GB | Boot volumes |
| **OKE Cluster** | Free | Basic clusters only |

Monitor usage: **OCI Console → Billing & Cost Management → Cost Analysis**

## 🔧 Common Commands

```bash
cd terraform/infra

# Show current workspace
terraform workspace show

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# View state
terraform state list
terraform state show <resource>

# Destroy infrastructure
terraform destroy
```

## 🐛 Troubleshooting

### AWS Checksum Error
If you see: `AWS chunked encoding not supported`

**Fix**: Set checksum environment variables
```bash
export AWS_REQUEST_CHECKSUM_CALCULATION="when_required"
export AWS_RESPONSE_CHECKSUM_VALIDATION="when_required"
```

### SignatureDoesNotMatch Error
If OCI authentication fails:

1. Verify Customer Secret Key is valid
2. Regenerate if needed: OCI Console → Profile → Customer Secret Keys
3. Update `~/.zshrc` with new credentials
4. Run `source ~/.zshrc`

### Terraform Init Fails
1. Test S3 connectivity:
   ```bash
   aws s3 ls s3://terraform-states/ \
     --endpoint-url https://grubbyvi3mov.compat.objectstorage.sa-saopaulo-1.oraclecloud.com
   ```

2. Verify versioning enabled:
   ```bash
   aws s3api get-bucket-versioning \
     --bucket terraform-states \
     --endpoint-url https://grubbyvi3mov.compat.objectstorage.sa-saopaulo-1.oraclecloud.com
   ```

See [SETUP-GUIDE.md](./docs/internal/SETUP-GUIDE.md) for detailed troubleshooting.

## 📝 Workspaces

This project uses Terraform workspaces for environment isolation:

- **default**: Initial workspace
- **dev**: Development/Lab environment (testing)

Each workspace has its own state file stored in the S3-compatible bucket:
```
s3://terraform-states/infra/terraform.tfstate.d/<workspace-name>/terraform.tfstate
```

## 🎯 Next Steps

1. **Add Infrastructure**:
   - Define resources in `main.tf`
   - Common resources: VCN, Subnet, OKE Cluster, Compute Instances

2. **Deploy in Dev**:
   ```bash
   terraform workspace select dev
   terraform plan
   terraform apply
   ```

## 📖 References

- [OCI Terraform Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [OCI Free Tier](https://www.oracle.com/cloud/free/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [OCI Object Storage S3 Compatibility](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/s3compatibleapi.htm)

## 📄 License

This project is configured for personal use on OCI Free Tier.

## 👤 Author

Igor Gevaerd - Initial setup and configuration

## 🤝 Contributing

This is a personal lab environment. Feel free to extend and adapt for your needs.

---

**Last Updated**: April 2026  
**Region**: sa-saopaulo-1 (São Paulo, Brazil)  
**Terraform Version**: >= 1.6.4
