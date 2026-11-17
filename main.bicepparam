using 'main.bicep'

param location = 'southeastasia'
param namePrefix = 'cacheaside'
param appServiceSku = 'B1'
param postgresSku = 'Standard_B1ms'
param redisSku = 'Balanced_B0'
param cacheTtlSeconds = 60
