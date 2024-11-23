#!/bin/sh

set -x

# Check if BASE_URL is set
if [ -z "$BASE_URL" ]; then
  echo "Error: BASE_URL environment variable is not set."
  exit 1
fi

echo "Replacing {{BASE_URL}} with $BASE_URL in all files within /public"

# Replace {{BASE_URL}} in all files under /public
find /public -type f -exec sed -i "s|{{BASE_URL}}|$BASE_URL|g" {} +

# Log completion
echo "Base URL replacement completed."

# If no arguments are passed to this wrapper script, set default to static-web-server
if [ -z "$1" ]; then
    set -- static-web-server
fi

# Forward all arguments to the original entrypoint script
exec /entrypoint.sh "$@"