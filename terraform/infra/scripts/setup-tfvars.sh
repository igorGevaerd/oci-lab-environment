#!/bin/bash

# Script to automatically generate terraform.tfvars from ~/.oci/config
# This script extracts OCI credentials and creates terraform variables

set -e

OCI_CONFIG="${HOME}/.oci/config"
TFVARS_FILE="../terraform.tfvars"
NAMESPACE="grubbyvi3mov"
ENVIRONMENT="dev"
PROJECT_NAME="oci-k8s-lab"

# Check if OCI config exists
if [ ! -f "$OCI_CONFIG" ]; then
    echo "Error: $OCI_CONFIG not found!"
    echo "Please configure OCI CLI first with: oci setup config"
    exit 1
fi

echo "📋 Extracting OCI credentials from $OCI_CONFIG..."

# Extract values from OCI config
USER_OCID=$(grep "^user=" "$OCI_CONFIG" | head -1 | cut -d= -f2 | xargs)
TENANCY_OCID=$(grep "^tenancy=" "$OCI_CONFIG" | head -1 | cut -d= -f2 | xargs)
FINGERPRINT=$(grep "^fingerprint=" "$OCI_CONFIG" | head -1 | cut -d= -f2 | xargs)
PRIVATE_KEY_PATH=$(grep "^key_file=" "$OCI_CONFIG" | head -1 | cut -d= -f2 | xargs)
REGION=$(grep "^region=" "$OCI_CONFIG" | head -1 | cut -d= -f2 | xargs)

# Validate required values
if [ -z "$USER_OCID" ] || [ -z "$TENANCY_OCID" ] || [ -z "$FINGERPRINT" ]; then
    echo "Error: Could not extract required values from $OCI_CONFIG"
    echo "Ensure your config has: user, tenancy, fingerprint, and key_file"
    exit 1
fi

# Default to sa-saopaulo-1 if not set or different
if [ "$REGION" != "sa-saopaulo-1" ]; then
    echo "⚠️  Warning: Region in OCI config is '$REGION', using 'sa-saopaulo-1' for Terraform"
    REGION="sa-saopaulo-1"
fi

# Create terraform.tfvars
cat > "$TFVARS_FILE" << EOF
# Terraform variables for OCI Infrastructure
# Auto-generated from ~/.oci/config
# Generated: $(date)

tenancy_ocid     = "$TENANCY_OCID"
user_ocid        = "$USER_OCID"
fingerprint      = "$FINGERPRINT"
private_key_path = "$PRIVATE_KEY_PATH"
region           = "$REGION"
namespace        = "$NAMESPACE"
environment      = "$ENVIRONMENT"
project_name     = "$PROJECT_NAME"
EOF

# Verify the file was created
if [ -f "$TFVARS_FILE" ]; then
    echo "✅ Created $TFVARS_FILE successfully!"
    echo ""
    echo "📝 Configuration Summary:"
    echo "   Region:      $REGION"
    echo "   Tenancy:     ${TENANCY_OCID:0:30}..."
    echo "   User:        ${USER_OCID:0:30}..."
    echo "   Fingerprint: ${FINGERPRINT:0:20}..."
    echo "   Key file:    $PRIVATE_KEY_PATH"
    echo "   Namespace:   $NAMESPACE"
    echo "   Environment: $ENVIRONMENT"
    echo ""
    echo "⚠️  IMPORTANT: $TFVARS_FILE contains sensitive data!"
    echo "   Make sure it's in .gitignore (it should be)"
    echo ""
    echo "Ready to run: terraform init"
else
    echo "❌ Failed to create $TFVARS_FILE"
    exit 1
fi
