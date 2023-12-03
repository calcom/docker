#!/bin/sh
 
# List of variables to replace
VARIABLES="NEXT_PUBLIC_WEBAPP_URL NEXT_PUBLIC_LICENSE_CONSENT CALCOM_TELEMETRY_DISABLED NEXTAUTH_SECRET CALENDSO_ENCRYPTION_KEY DATABASE_URL"
 
for VAR in $VARIABLES; do
    # Retrieve the current value of the variable
    TO_VALUE=$(eval echo \$$VAR)
 
    # Only proceed if the variable is set and not empty
    if [ ! -z "$TO_VALUE" ]; then
        FROM_PLACEHOLDER="PLACEHOLDER_${VAR}"
        echo "Replacing $FROM_PLACEHOLDER with $TO_VALUE"
 
        find apps/web/.next/ apps/web/public -type f |
        while read file; do
            sed -i "s|$FROM_PLACEHOLDER|$TO_VALUE|g" "$file"
        done
    else
        echo "Variable $VAR is not set. Skipping replacement for $VAR."
    fi
done