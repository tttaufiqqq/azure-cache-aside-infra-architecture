#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-cache-aside-lab}"

echo "This deletes the resource group ${RESOURCE_GROUP} and everything in it."
read -r -p "Type the resource group name to confirm: " answer
if [[ "${answer}" != "${RESOURCE_GROUP}" ]]; then
  echo "Name does not match. Cancelled."
  exit 1
fi

az group delete --name "${RESOURCE_GROUP}" --yes --no-wait
echo "Deletion started. Check progress with: az group exists --name ${RESOURCE_GROUP}"
