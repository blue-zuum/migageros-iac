// ============================================================
// database.bicep — Migageros S.A.
// Módulo de Base de Datos Relacional (Azure SQL)
// ============================================================

@description('Ambiente: dev o prod')
param environment string

@description('Nombre del aplicativo o sistema')
param appName string

@description('Región de Azure')
param location string

@description('Contraseña de administrador de SQL')
@secure()
param sqlAdminPassword string

@description('Nivel de rendimiento de base de datos')
@allowed(['Basic', 'Standard', 'Premium'])
param databaseTier string = 'Basic'

var uniqueSuffix = take(uniqueString(resourceGroup().id), 6)
var sqlServerName = take('sql-mg-${appName}-${environment}-${uniqueSuffix}', 63)
var databaseName = 'db-migageros-${environment}'
var adminUser = 'migadmin'

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: adminUser
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
  }
}

// Permite conexión interna desde la Web App de Migageros S.A.
resource firewallRule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: databaseTier // 'Basic' es muy económico (~$5 USD/mes)
    tier: databaseTier
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    requestedBackupStorageRedundancy: 'Local'
  }
}

output sqlServerId string = sqlServer.id
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output databaseName string = sqlDb.name
