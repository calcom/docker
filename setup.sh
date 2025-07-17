#!/bin/bash

# Cal.com Docker Setup Script
# This script generates secure secrets and prepares the environment

set -e

ENV_FILE=".env"

echo "🚀 Setting up Cal.com Docker environment..."

# Check if .env exists, if not copy from example
if [ ! -f "$ENV_FILE" ]; then
    echo "📋 Creating .env file from .env.example..."
    cp .env.example .env
fi

# Generate NEXTAUTH_SECRET if it's still the default
if grep -q "NEXTAUTH_SECRET=secret" "$ENV_FILE"; then
    echo "🔐 Generating NEXTAUTH_SECRET..."
    NEXTAUTH_SECRET=$(openssl rand -base64 32)
    sed -i "s/NEXTAUTH_SECRET=secret/NEXTAUTH_SECRET=$NEXTAUTH_SECRET/" "$ENV_FILE"
fi

# Generate CALENDSO_ENCRYPTION_KEY if it's still the default
if grep -q "CALENDSO_ENCRYPTION_KEY=secret" "$ENV_FILE"; then
    echo "🔑 Generating CALENDSO_ENCRYPTION_KEY (24 characters for 2FA support)..."
    CALENDSO_ENCRYPTION_KEY=$(openssl rand -base64 24)
    sed -i "s/CALENDSO_ENCRYPTION_KEY=secret/CALENDSO_ENCRYPTION_KEY=$CALENDSO_ENCRYPTION_KEY/" "$ENV_FILE"
fi

echo "✅ Environment setup complete!"
echo ""
echo "🔧 Generated secrets:"
echo "   - NEXTAUTH_SECRET: ✓"
echo "   - CALENDSO_ENCRYPTION_KEY: ✓ (24 chars - fixes 2FA issue)"
echo ""
echo "📝 Next steps:"
echo "   1. Review and customize other settings in .env"
echo "   2. Run: docker compose up --build"
echo ""
echo "⚠️  Important: The generated secrets are saved in .env"
echo "   Keep this file secure and don't commit it to version control!"