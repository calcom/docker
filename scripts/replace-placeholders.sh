# Find and replace placeholder values with runtime-specific environment values
find apps/web/.next/ apps/web/public -type f |
while read file; do
    sed -i "s|https://NEXT_PUBLIC_WEBAPP_URL_PLACEHOLDER|$NEXT_PUBLIC_WEBAPP_URL|g" "$file"
done
