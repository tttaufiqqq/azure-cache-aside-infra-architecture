@description('Cache name. It becomes part of the host name.')
param cacheName string

@description('Azure region.')
param location string

@description('Tags applied to every resource.')
param tags object

@description('Azure Managed Redis SKU.')
param skuName string = 'Balanced_B0'

@description('Object ID of the app managed identity.')
param principalId string

@description('Log Analytics workspace ID for diagnostics.')
param workspaceId string

resource cluster 'Microsoft.Cache/redisEnterprise@2025-07-01' = {
  name: cacheName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    minimumTlsVersion: '1.2'
    highAvailability: 'Disabled'
    publicNetworkAccess: 'Disabled'
  }
}

resource database 'Microsoft.Cache/redisEnterprise/databases@2025-07-01' = {
  parent: cluster
  name: 'default'
  properties: {
    clientProtocol: 'Encrypted'
    port: 10000
    clusteringPolicy: 'EnterpriseCluster'
    evictionPolicy: 'VolatileLRU'
    accessKeysAuthentication: 'Disabled'
  }
}

resource appAccess 'Microsoft.Cache/redisEnterprise/databases/accessPolicyAssignments@2025-07-01' = {
  parent: database
  name: 'app'
  properties: {
    accessPolicyName: 'default'
    user: {
      objectId: principalId
    }
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: cluster
  name: 'to-log-analytics'
  properties: {
    workspaceId: workspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output id string = cluster.id
output name string = cluster.name
output hostName string = cluster.properties.hostName
output port int = database.properties.port
