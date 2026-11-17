# Deploy, redeploy, and destroy

This article shows how to deploy the infrastructure, change it, and delete it.

## Before you begin

- Sign in with `az login`.
- Select your subscription with `az account set --subscription "<name>"`.
- Confirm that Azure Managed Redis and your chosen SKUs are available in the target region.

## Deploy

Run the deploy script from the repository root.

```bash
./scripts/deploy.sh
```

The script:

1. Creates the resource group.
1. Runs `az deployment group what-if` and shows the planned changes.
1. Asks for confirmation.
1. Deploys `main.bicep` with `main.bicepparam`.
1. Prints the deployment outputs.

Deployment can take several minutes because Redis and PostgreSQL provision slowly.

## Change the configuration

Edit `main.bicepparam`, then run `./scripts/deploy.sh` again.

| Parameter | Default | Description |
|---|---|---|
| `location` | `southeastasia` | Azure region |
| `namePrefix` | `cacheaside` | Prefix for resource names |
| `appServiceSku` | `B1` | App Service plan size |
| `postgresSku` | `Standard_B1ms` | PostgreSQL compute size |
| `redisSku` | `Balanced_B0` | Azure Managed Redis size |
| `cacheTtlSeconds` | `60` | Default cache TTL |

You can override the resource group and region with environment variables.

```bash
RESOURCE_GROUP=my-rg LOCATION=eastasia ./scripts/deploy.sh
```

## Use the outputs

The deployment prints `appName`, `appUrl`, `postgresHost`, and `redisHost`. The `cache-aside-app` repository reads `appName` to deploy the app.

## Destroy

Run the destroy script.

```bash
./scripts/destroy.sh
```

The script asks you to type the resource group name, then runs `az group delete --no-wait`. Deletion continues in the background.

Check whether the group still exists.

```bash
az group exists --name rg-cache-aside-lab
```

## Redeploy

After deletion finishes, run `./scripts/deploy.sh` again. The name suffix comes from the resource group ID, so a recreated group in the same subscription reuses the same names.
