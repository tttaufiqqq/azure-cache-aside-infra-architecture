@description('Globally unique web app name.')
param appName string

@description('App Service plan name.')
param planName string

@description('Azure region.')
param location string

@description('Tags applied to every resource.')
param tags object

@description('App Service plan SKU. VNet integration needs Basic or higher.')
param skuName string = 'B1'

@description('Node.js runtime stack.')
param nodeVersion string = 'NODE|22-lts'

@description('Subnet ID for virtual network integration.')
param subnetId string

@description('Resource ID of the user-assigned managed identity.')
param identityId string

@description('Client ID of the managed identity.')
param identityClientId string

@description('Name of the managed identity. It is the PostgreSQL role name.')
param identityName string

@description('PostgreSQL host name.')
param postgresHost string

@description('PostgreSQL database name.')
param postgresDatabase string

@description('Redis host name.')
param redisHost string

@description('Redis TLS port.')
param redisPort int

@description('Default cache TTL in seconds.')
param cacheTtlSeconds int = 60

@description('Application Insights connection string.')
param appInsightsConnectionString string

@description('Log Analytics workspace ID for diagnostics.')
param workspaceId string

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: skuName
  }
  properties: {
    reserved: true
  }
}

resource site 'Microsoft.Web/sites@2023-12-01' = {
  name: appName
  location: location
  tags: tags
  kind: 'app,linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    virtualNetworkSubnetId: subnetId
    vnetRouteAllEnabled: true
    siteConfig: {
      linuxFxVersion: nodeVersion
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      healthCheckPath: '/health'
      appSettings: [
        {
          name: 'AZURE_CLIENT_ID'
          value: identityClientId
        }
        {
          name: 'PGHOST'
          value: postgresHost
        }
        {
          name: 'PGDATABASE'
          value: postgresDatabase
        }
        {
          name: 'PGUSER'
          value: identityName
        }
        {
          name: 'REDIS_HOST'
          value: redisHost
        }
        {
          name: 'REDIS_PORT'
          value: string(redisPort)
        }
        {
          name: 'CACHE_TTL_SECONDS'
          value: string(cacheTtlSeconds)
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
      ]
    }
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: site
  name: 'to-log-analytics'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output name string = site.name
output url string = 'https://${site.properties.defaultHostName}'
