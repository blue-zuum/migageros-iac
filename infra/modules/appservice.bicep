// ============================================================
// appservice.bicep — Migageros S.A.
// Módulo de Cómputo Web PaaS (Linux F1 100% Gratuito en West US)
// ============================================================

@description('Ambiente: dev o prod')
param environment string

@description('Nombre del aplicativo o sistema')
param appName string

@description('Región de Azure (westus)')
param location string = 'westus'

@description('Tamaño de cómputo (F1 = Nivel Gratuito para estudiantes)')
param skuName string = 'F1'

var planName = 'asp-migageros-${appName}-${environment}'
var webSiteName = 'app-migageros-${appName}-${environment}'

// 1. Plan de Hospedaje en Linux Free (F1)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: planName
  location: location
  kind: 'linux'
  sku: {
    name: skuName
    tier: 'Free'
  }
  properties: {
    reserved: true
  }
}

// 2. Aplicación Web PaaS de Migageros S.A.
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webSiteName
  location: location
  identity: {
    type: 'SystemAssigned' // Identidad administrada para consultar Key Vault sin contraseñas
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
  }
}

output appServiceId string = webApp.id
output appServiceUrl string = 'https://${webApp.properties.defaultHostName}'
output principalId string = webApp.identity.principalId
