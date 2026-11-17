# Cache-aside on Azure: infrastructure

This is a learning project. It implements the architecture from the Azure Architecture Center article [Cache-aside caching using Azure Managed Redis and Azure Database for PostgreSQL](https://learn.microsoft.com/en-us/azure/architecture/databases/architecture/cache-aside-azure-managed-redis-postgresql) with Bicep, so you can deploy it, test it, and delete it at any time.

> [!NOTE]
> This is a personal learning implementation. It is not official Microsoft guidance.

This repository contains the Azure infrastructure. The web app lives in a separate repository, `cache-aside-app`.

![Architecture diagram of the cache-aside pattern with Azure Managed Redis and Azure Database for PostgreSQL](diagrams/architecture.png)

Diagram source: [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/databases/architecture/cache-aside-azure-managed-redis-postgresql).

## Learning goals

- Understand the cache-aside pattern, including its read path, write path, and failure modes.
- Connect App Service to data services over private endpoints.
- Authenticate with a managed identity and Microsoft Entra ID instead of passwords or keys.
- Deploy and delete a complete environment with Bicep.

## What this deploys

| Resource | Purpose |
|---|---|
| App Service (Linux, B1) | Hosts the web app |
| Azure Managed Redis (Balanced B0) | Stores cached data |
| Azure Database for PostgreSQL flexible server (Burstable B1ms) | Stores the source of truth |
| Virtual network, two subnets, two private endpoints | Keeps data traffic off the public internet |
| Two private DNS zones | Resolve the private endpoints |
| User-assigned managed identity | Authenticates the app to both data services |
| Log Analytics workspace and Application Insights | Collect logs and metrics |

For a full explanation, see [Architecture](docs/architecture.md).

## Prerequisites

- An Azure subscription
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) with Bicep (`az bicep install`)
- Permission to create resources in your subscription

## Quickstart

1. Sign in to Azure.

   ```bash
   az login
   ```

1. Deploy the infrastructure.

   ```bash
   ./scripts/deploy.sh
   ```

   The script previews the changes and asks for confirmation before it deploys.

1. Deploy the web app by following the `cache-aside-app` repository.

1. Delete everything when you finish.

   ```bash
   ./scripts/destroy.sh
   ```

For more detail, see [Deploy, redeploy, and destroy](docs/deploy.md).

> [!WARNING]
> Azure Managed Redis, PostgreSQL, App Service, and private endpoints all bill while they exist. Run `./scripts/destroy.sh` when you finish.

## Differences from the reference architecture

| Reference architecture | This project | Reason |
|---|---|---|
| High availability for Redis and PostgreSQL | Turned off | Lower cost |
| Production sizing | Smallest SKUs | Learning only |
| Least-privilege database roles | App identity is a PostgreSQL Entra administrator | Lets the app create its own schema |
| Durable invalidation, such as an outbox | Not implemented | The TTL limits stale data |

## What I learned

Add your own notes here as you work through the project.

## Related resources

- `cache-aside-app`: the web app repository
- [Troubleshooting](docs/troubleshooting.md)
- [Azure Architecture Center article](https://learn.microsoft.com/en-us/azure/architecture/databases/architecture/cache-aside-azure-managed-redis-postgresql)
