// ============================================================
// keyvault.bicep — Migageros S.A.
// Módulo de Bóveda de Secretos y Credenciales Cifradas
// ============================================================

@description('Ambiente: dev o prod')
param environment string

@description('Nombre del aplicativo o sistema')
param appName string

@description('Región de Azure')
param location string

@description('Contraseña de base de datos a proteger')
@secure()
param sqlAdminPassword string

@description('Identidad del App Service')
param appServiceIdentityId string

var uniqueSuffix = take(uniqueString(resourceGroup().id), 5)
var cleanApp = take(toLower(replace(appName, '-', '')), 8)
var keyVaultName = take('kv-mg-${cleanApp}-${environment}-${uniqueSuffix}', 24)

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: appServiceIdentityId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

resource secretSqlPassword 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'sql-admin-password'
  properties: {
    value: sqlAdminPassword
  }
}

output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
