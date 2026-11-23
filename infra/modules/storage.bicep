// ============================================================
// storage.bicep — Migageros S.A.
// Módulo de Almacenamiento Seguro (Blobs) para Aplicativos
// ============================================================

@description('Ambiente: dev o prod')
param environment string

@description('Nombre del aplicativo o módulo')
param appName string

@description('Región de Azure')
param location string

var uniqueSuffix = take(uniqueString(resourceGroup().id), 6)
var cleanAppName = toLower(replace(appName, '-', ''))
var storageAccountName = take('stmg${cleanAppName}${environment}${uniqueSuffix}', 24)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS' // Redundancia Local: la opción más económica para desarrollo y pruebas
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false // Protección contra filtraciones públicas
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: 'archivos-sistema'
  properties: {
    publicAccess: 'None'
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
