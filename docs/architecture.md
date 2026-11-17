# Architecture

This article explains the resources this project deploys and why each one exists. It follows the [Azure Architecture Center reference architecture](https://learn.microsoft.com/en-us/azure/architecture/databases/architecture/cache-aside-azure-managed-redis-postgresql).

## The cache-aside pattern

The app owns the cache logic. Redis stores copies of data, and PostgreSQL stays the source of truth.

**Read path**

1. The app checks Redis for the key.
1. On a hit, the app returns the cached value.
1. On a miss, the app queries PostgreSQL, returns the result, and stores it in Redis with a time to live (TTL).

**Write path**

1. The app commits the change to PostgreSQL.
1. The app deletes the affected key from Redis.
1. The next read refills the cache with fresh data.

If Redis is unavailable, the app reads from PostgreSQL directly. A failed cache operation never fails a committed write.

## Resources

| Resource | Module | Notes |
|---|---|---|
| Managed identity | `modules/identity.bicep` | Created first because both data services reference it |
| Log Analytics and Application Insights | `modules/monitor.bicep` | Receive logs and metrics from every component |
| Virtual network and private DNS | `modules/network.bicep` | One subnet for App Service integration and one for private endpoints |
| PostgreSQL flexible server | `modules/postgres.bicep` | Public access off, Entra authentication on, password authentication off |
| Azure Managed Redis | `modules/redis.bicep` | Public access off, access keys off, Entra authentication on |
| Private endpoints | `modules/private-endpoints.bicep` | One for each data service, with DNS zone groups |
| App Service | `modules/appservice.bicep` | VNet integration, health check, diagnostics |

## Network flow

1. App Service sends traffic through its integrated subnet.
1. Private DNS resolves the Redis and PostgreSQL host names to private IP addresses.
1. The private endpoints forward traffic to each service.

Both data services reject public traffic, so you can't connect to them from your own computer.

## Identity

One user-assigned managed identity authenticates the app to both services.

- **Redis:** the identity receives the `default` data access policy.
- **PostgreSQL:** the identity is a Microsoft Entra administrator. The app connects as that role and creates its own schema at startup.

> [!NOTE]
> Making the app identity a PostgreSQL administrator is broader than production least privilege. It avoids a manual SQL step that you can't run against a private-only database.

## Monitoring

Each component sends logs and metrics to the Log Analytics workspace. The app also reports to Application Insights. Use these signals to watch for:

- cache hits and misses
- cache fill failures
- invalidation failures
- slow database queries

## Design decisions

| Decision | Reason |
|---|---|
| Bicep instead of Terraform | No extra install and no state file |
| One resource group | `az group delete` removes everything |
| Smallest SKUs | Lowest cost for a learning project |
| Name suffix from `uniqueString` | Avoids global name collisions between deployments |
