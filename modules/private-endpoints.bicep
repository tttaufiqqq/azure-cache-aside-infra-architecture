@description('Name prefix for private endpoints.')
param namePrefix string

@description('Azure region.')
param location string

@description('Tags applied to every resource.')
param tags object

@description('Subnet ID for private endpoints.')
param subnetId string

@description('PostgreSQL server resource ID.')
param postgresId string

@description('Redis cluster resource ID.')
param redisId string

@description('Private DNS zone ID for PostgreSQL.')
param postgresZoneId string

@description('Private DNS zone ID for Redis.')
param redisZoneId string

resource postgresEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: '${namePrefix}-pe-postgres'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'postgres'
        properties: {
          privateLinkServiceId: postgresId
          groupIds: [
            'postgresqlServer'
          ]
        }
      }
    ]
  }
}

resource postgresDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: postgresEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'postgres'
        properties: {
          privateDnsZoneId: postgresZoneId
        }
      }
    ]
  }
}

resource redisEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: '${namePrefix}-pe-redis'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'redis'
        properties: {
          privateLinkServiceId: redisId
          groupIds: [
            'redisEnterprise'
          ]
        }
      }
    ]
  }
}

resource redisDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: redisEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'redis'
        properties: {
          privateDnsZoneId: redisZoneId
        }
      }
    ]
  }
}
