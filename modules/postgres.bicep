@description('Globally unique server name.')
param serverName string

@description('Azure region.')
param location string

@description('Tags applied to every resource.')
param tags object

@description('Compute SKU name.')
param skuName string = 'Standard_B1ms'

@description('Compute tier.')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'Burstable'

@description('PostgreSQL major version.')
param postgresVersion string = '16'

@description('Storage size in GB.')
param storageSizeGB int = 32

@description('Database name.')
param databaseName string = 'appdb'

@description('Object ID of the app managed identity.')
param adminPrincipalId string

@description('Name of the app managed identity. It becomes the PostgreSQL role name.')
param adminPrincipalName string

@description('Log Analytics workspace ID for diagnostics.')
param workspaceId string

resource server 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: serverName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    version: postgresVersion
    createMode: 'Default'
    storage: {
      storageSizeGB: storageSizeGB
    }
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: tenant().tenantId
    }
    network: {
      publicNetworkAccess: 'Disabled'
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}

resource database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2024-08-01' = {
  parent: server
  name: databaseName
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

resource entraAdmin 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2024-08-01' = {
  parent: server
  name: adminPrincipalId
  properties: {
    principalType: 'ServicePrincipal'
    principalName: adminPrincipalName
    tenantId: tenant().tenantId
  }
  dependsOn: [
    database
  ]
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: server
  name: 'to-log-analytics'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
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

output id string = server.id
output name string = server.name
output fqdn string = server.properties.fullyQualifiedDomainName
output databaseName string = database.name
