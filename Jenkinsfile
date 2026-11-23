// ============================================================
// Jenkinsfile — Migageros S.A.
// Pipeline CI/CD en Jenkins para Automatización con Azure Bicep
// ============================================================

pipeline {
    // Se ejecuta en cualquier agente o nodo de Jenkins con Azure CLI instalado
    agent any

    environment {
        AZURE_LOCATION = 'centralus'
        RG_DEV         = 'rg-migageros-erp-dev'
        RG_PROD        = 'rg-migageros-erp-prod'
    }

    stages {
        // -------------------------------------------------------------
        // FASE 1: DESCARGA DE CÓDIGO
        // -------------------------------------------------------------
        stage('1. Checkout del Repositorio') {
            steps {
                echo "Descargando codigo fuente desde GitHub..."
                checkout scm
            }
        }

        // -------------------------------------------------------------
        // FASE 2: VALIDACIÓN DE BICEP (Quality Gate)
        // -------------------------------------------------------------
        stage('2. Validar Código Bicep') {
            steps {
                echo "Instalando y verificando compilacion de Azure Bicep..."
                bat 'az bicep install'
                bat 'az bicep build --file infra/main.bicep'
            }
        }

        // -------------------------------------------------------------
        // FASE 3: SIMULACIÓN DE CAMBIOS (What-If)
        // -------------------------------------------------------------
        stage('3. Simulación de Cambios (What-If)') {
            steps {
                echo "Ejecutando simulacion What-If en Azure..."
                bat """
                    az deployment group what-if ^
                      --resource-group ${RG_DEV} ^
                      --template-file infra/main.bicep ^
                      --parameters infra/parameters/dev.bicepparam ^
                      --parameters sqlAdminPassword="Migageros2026!P@ss"
                """
            }
        }

        // -------------------------------------------------------------
        // FASE 4: DESPLIEGUE A AMBIENTE DEV
        // -------------------------------------------------------------
        stage('4. Despliegue en DEV') {
            when {
                branch 'dev'
            }
            steps {
                echo "Provisionando infraestructura en Azure para Migageros S.A...."
                bat """
                    az deployment group create ^
                      --name "deploy-dev-jenkins-${BUILD_NUMBER}" ^
                      --resource-group ${RG_DEV} ^
                      --template-file infra/main.bicep ^
                      --parameters infra/parameters/dev.bicepparam ^
                      --parameters sqlAdminPassword="Migageros2026!P@ss"
                """
            }
        }

        // -------------------------------------------------------------
        // FASE 5: DESPLIEGUE A PRODUCCIÓN (Con Aprobación Manual)
        // -------------------------------------------------------------
        stage('5. Aprobación y Despliegue en PROD') {
            when {
                branch 'main'
            }
            steps {
                // Pausa el pipeline esperando confirmación de un supervisor
                input message: '¿Autoriza desplegar la infraestructura en PRODUCCIÓN?', ok: 'Aprobar Despliegue'
                
                echo "Desplegando en ambiente de PRODUCCION..."
                bat """
                    az deployment group create ^
                      --name "deploy-prod-jenkins-${BUILD_NUMBER}" ^
                      --resource-group ${RG_PROD} ^
                      --template-file infra/main.bicep ^
                      --parameters infra/parameters/prod.bicepparam ^
                      --parameters sqlAdminPassword="Migageros2026!P@ss"
                """
            }
        }
    }

    post {
        success {
            echo "El pipeline de Jenkins finalizo con EXITO total. Infraestructura creada en Azure."
        }
        failure {
            echo "Error en la ejecucion del pipeline. Revise los registros de la consola."
        }
    }
}
