@description('Name prefix for network resources.')
param namePrefix string

@description('Azure region.')
param location string

@description('Tags applied to every resource.')
param tags object

@description('Address space of the virtual network.')
param vnetAddressPrefix string = '10.20.0.0/16'

@description('Subnet for App Service virtual network integration.')
param appSubnetPrefix string = '10.20.1.0/24'

@description('Subnet for private endpoints.')
param privateEndpointSubnetPrefix string = '10.20.2.0/24'

var postgresZoneName = 'privatelink.postgres.database.azure.com'
var redisZoneName = 'privatelink.redis.azure.net'

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: '${namePrefix}-vnet'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-app'
        properties: {
          addressPrefix: appSubnetPrefix
          delegations: [
            {
              name: 'appservice'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'snet-private-endpoints'
        properties: {
          addressPrefix: privateEndpointSubnetPrefix
        }
      }
    ]
  }
}

resource postgresZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: postgresZoneName
  location: 'global'
  tags: tags
}

resource redisZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: redisZoneName
  location: 'global'
  tags: tags
}

resource postgresLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: postgresZone
  name: '${namePrefix}-postgres-link'
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource redisLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: redisZone
  name: '${namePrefix}-redis-link'
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

output appSubnetId string = vnet.properties.subnets[0].id
output privateEndpointSubnetId string = vnet.properties.subnets[1].id
output postgresZoneId string = postgresZone.id
output redisZoneId string = redisZone.id
