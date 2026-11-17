#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-cache-aside-lab}"
LOCATION="${LOCATION:-southeastasia}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

az account show --query "{subscription:name, user:user.name}" -o table

echo "Creating resource group ${RESOURCE_GROUP} in ${LOCATION}..."
az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}" -o none

echo "Previewing changes..."
az deployment group what-if \
  --resource-group "${RESOURCE_GROUP}" \
  --parameters "${ROOT}/main.bicepparam" \
  --parameters location="${LOCATION}"

read -r -p "Deploy these changes? [y/N] " answer
if [[ "${answer}" != "y" && "${answer}" != "Y" ]]; then
  echo "Cancelled."
  exit 0
fi

az deployment group create \
  --name cache-aside \
  --resource-group "${RESOURCE_GROUP}" \
  --parameters "${ROOT}/main.bicepparam" \
  --parameters location="${LOCATION}" \
  --query properties.outputs -o json
