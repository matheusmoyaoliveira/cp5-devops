#!/bin/bash
# Cria o monitoramento (Log Analytics + Application Insights), o App Service Plan,
# o Web App Java 17 e configura as variáveis de ambiente (banco + Insights).
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/variaveis.sh"

read -s -p "Senha do administrador do SQL Server (a mesma do script 01): " SQL_ADMIN_PASSWORD
echo

echo ">> Registrando os provedores e a extensão do Application Insights"
az provider register --namespace Microsoft.Web --wait
az provider register --namespace Microsoft.Insights --wait
az provider register --namespace Microsoft.OperationalInsights --wait
az extension add --name application-insights --upgrade --yes

echo ">> Criando o Log Analytics Workspace $LOG_WORKSPACE_NAME"
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP_NAME \
  --workspace-name $LOG_WORKSPACE_NAME \
  --location "$LOCATION"

echo ">> Criando o Application Insights $APP_INSIGHTS_NAME"
az monitor app-insights component create \
  --app $APP_INSIGHTS_NAME \
  --location "$LOCATION" \
  --resource-group $RESOURCE_GROUP_NAME \
  --application-type web \
  --workspace $LOG_WORKSPACE_NAME

echo ">> Criando o App Service Plan $APP_SERVICE_PLAN (F1 Linux)"
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP_NAME \
  --location "$LOCATION" \
  --sku F1 \
  --is-linux

echo ">> Criando o Web App $WEBAPP_NAME ($RUNTIME)"
az webapp create \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --plan $APP_SERVICE_PLAN \
  --runtime "$RUNTIME"

echo ">> Configurando as variáveis de ambiente (banco + Application Insights)"
CONNECTION_STRING=$(az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --query connectionString \
  --output tsv)

JDBC_URL="jdbc:sqlserver://$SQL_SERVER_NAME.database.windows.net:1433;database=$SQL_DATABASE_NAME;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30"

az webapp config appsettings set \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --settings \
    APPLICATIONINSIGHTS_CONNECTION_STRING="$CONNECTION_STRING" \
    ApplicationInsightsAgent_EXTENSION_VERSION="~3" \
    XDT_MicrosoftApplicationInsights_Mode="Recommended" \
    XDT_MicrosoftApplicationInsights_PreemptSdk="1" \
    SPRING_DATASOURCE_URL="$JDBC_URL" \
    SPRING_DATASOURCE_USERNAME="$SQL_ADMIN_USER" \
    SPRING_DATASOURCE_PASSWORD="$SQL_ADMIN_PASSWORD" \
  --output none

echo ">> Ativando os logs do container (Log Stream)"
az webapp log config \
  --name $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --docker-container-logging filesystem

echo ">> Conectando o Web App ao Application Insights"
az monitor app-insights component connect-webapp \
  --app $APP_INSIGHTS_NAME \
  --web-app $WEBAPP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --output none

echo ">> Web App pronto: https://$WEBAPP_NAME.azurewebsites.net (falta o deploy: 03-deploy.sh)"
