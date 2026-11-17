# Troubleshooting

This article lists common deployment problems and how to resolve them.

## Read the deployment error

Show the failed operations for the deployment.

```bash
az deployment operation group list \
  --resource-group rg-cache-aside-lab \
  --name cache-aside \
  --query "[?properties.provisioningState=='Failed'].properties.statusMessage"
```

## The region or SKU is unavailable

**Symptom:** Redis or PostgreSQL fails to create with a capacity, region, or SKU error.

**Fix:** Change `location` or the SKU in `main.bicepparam`. Check that Azure Managed Redis is available in the region you choose.

## The app resolves a public IP address

**Symptom:** The app can't reach Redis or PostgreSQL, and DNS returns a public address.

**Fix:**

1. Confirm that each private DNS zone has a virtual network link.
1. Confirm that each private endpoint has a DNS zone group.
1. Confirm that `vnetRouteAllEnabled` is `true` on the web app.

Test resolution from the app's SSH console in the Kudu site.

```bash
nslookup <redisHost>
```

## The app can't authenticate to Redis

**Symptom:** The app connects but Redis rejects the login.

**Fix:**

- Confirm that the access policy assignment exists on the `default` database.
- Confirm that `AZURE_CLIENT_ID` matches the managed identity client ID.
- Use the host name from the `redisHost` output, not the `privatelink` name.

## The app can't authenticate to PostgreSQL

**Symptom:** PostgreSQL rejects the connection or the role doesn't exist.

**Fix:**

- Confirm that the identity is listed as a Microsoft Entra administrator on the server.
- Confirm that `PGUSER` equals the managed identity name.
- Check the app logs in Log Analytics for token errors.

## The deployment fails with a name conflict

**Symptom:** A resource name is already taken.

**Fix:** Change `namePrefix` in `main.bicepparam`. Names are global for PostgreSQL, Redis, and the web app.
