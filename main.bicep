targetScope = 'resourceGroup'

@description('Azure region. Check that Azure Managed Redis is available there.')
param location string = resourceGroup().location

@description('Short lowercase prefix for resource names.')
@minLength(3)
@maxLength(12)
param namePrefix string = 'cacheaside'

@description('App Service plan SKU.')
param appServiceSku string = 'B1'

@description('PostgreSQL compute SKU.')
param postgresSku string = 'Standard_B1ms'

@description('Azure Managed Redis SKU.')
param redisSku string = 'Balanced_B0'

@description('Default cache TTL in seconds.')
param cacheTtlSeconds int = 60

@description('Tags applied to every resource.')
param tags object = {
  project: 'cache-aside-learning'
}

var suffix = take(uniqueString(resourceGroup().id), 6)
var baseName = '${namePrefix}-${suffix}'

module identity 'modules/identity.bicep' = {
  name: 'identity'
  params: {
    name: '${baseName}-id'
    location: location
    tags: tags
  }
}

module monitor 'modules/monitor.bicep' = {
  name: 'monitor'
  params: {
    namePrefix: baseName
    location: location
    tags: tags
  }
}

module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    namePrefix: baseName
    location: location
    tags: tags
  }
}

module postgres 'modules/postgres.bicep' = {
  name: 'postgres'
  params: {
    serverName: '${baseName}-pg'
    location: location
    tags: tags
    skuName: postgresSku
    adminPrincipalId: identity.outputs.principalId
    adminPrincipalName: identity.outputs.name
    workspaceId: monitor.outputs.workspaceId
  }
}

module redis 'modules/redis.bicep' = {
  name: 'redis'
  params: {
    cacheName: '${baseName}-redis'
    location: location
    tags: tags
    skuName: redisSku
    principalId: identity.outputs.principalId
    workspaceId: monitor.outputs.workspaceId
  }
}

module privateEndpoints 'modules/private-endpoints.bicep' = {
  name: 'private-endpoints'
  params: {
    namePrefix: baseName
    location: location
    tags: tags
    subnetId: network.outputs.privateEndpointSubnetId
    postgresId: postgres.outputs.id
    redisId: redis.outputs.id
    postgresZoneId: network.outputs.postgresZoneId
    redisZoneId: network.outputs.redisZoneId
  }
}

module appService 'modules/appservice.bicep' = {
  name: 'app-service'
  params: {
    appName: '${baseName}-app'
    planName: '${baseName}-plan'
    location: location
    tags: tags
    skuName: appServiceSku
    subnetId: network.outputs.appSubnetId
    identityId: identity.outputs.id
    identityClientId: identity.outputs.clientId
    identityName: identity.outputs.name
    postgresHost: postgres.outputs.fqdn
    postgresDatabase: postgres.outputs.databaseName
    redisHost: redis.outputs.hostName
    redisPort: redis.outputs.port
    cacheTtlSeconds: cacheTtlSeconds
    appInsightsConnectionString: monitor.outputs.appInsightsConnectionString
    workspaceId: monitor.outputs.workspaceId
  }
  dependsOn: [
    privateEndpoints
  ]
}

output appName string = appService.outputs.name
output appUrl string = appService.outputs.url
output postgresHost string = postgres.outputs.fqdn
output redisHost string = redis.outputs.hostName
