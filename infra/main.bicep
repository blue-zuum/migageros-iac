// ============================================================
// main.bicep — Migageros S.A.
// Orquestador Maestro de Infraestructura como Código (IaC)
// ============================================================

@description('Ambiente a desplegar: dev (desarrollo) o prod (producción)')
@allowed(['dev', 'prod'])
param environment string

@description('Nombre del aplicativo de Migageros S.A.')
param appName string = 'erp'

@description('Ubicación de Azure heredada del Resource Group')
param location string = resourceGroup().location

@description('Contraseña para el administrador SQL')
@secure()
param sqlAdminPassword string = ''

// Selección dinámica de hardware cloud según el ambiente (F1 es gratis para estudiantes)
var appServiceSku = (environment == 'prod') ? 'B1' : 'F1'
var sqlDatabaseTier = (environment == 'prod') ? 'Standard' : 'Basic'

// 1. Almacenamiento seguro
module storageModule 'modules/storage.bicep' = {
  name: 'dep-storage-${environment}'
  params: {
    environment: environment
    appName: appName
    location: location
  }
}

// 2. Cómputo PaaS (Web App en westus con cupo libre F1)
module appServiceModule 'modules/appservice.bicep' = {
  name: 'dep-appservice-${environment}'
  params: {
    environment: environment
    appName: appName
    location: 'westus'
    skuName: 'F1'
  }
}

// 3. Base de datos SQL
module databaseModule 'modules/database.bicep' = {
  name: 'dep-database-${environment}'
  params: {
    environment: environment
    appName: appName
    location: location
    sqlAdminPassword: sqlAdminPassword
    databaseTier: sqlDatabaseTier
  }
}

// 4. Bóveda de credenciales
module keyVaultModule 'modules/keyvault.bicep' = {
  name: 'dep-keyvault-${environment}'
  params: {
    environment: environment
    appName: appName
    location: location
    sqlAdminPassword: sqlAdminPassword
    appServiceIdentityId: appServiceModule.outputs.principalId
  }
}

// Outputs informativos que se imprimirán en consola y en el pipeline
output appServiceUrl string = appServiceModule.outputs.appServiceUrl
output sqlServerHost string = databaseModule.outputs.sqlServerFqdn
output databaseName string = databaseModule.outputs.databaseName
output storageName string = storageModule.outputs.storageAccountName
output keyVaultName string = keyVaultModule.outputs.keyVaultName
