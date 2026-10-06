#!/bin/bash
# Mostra no terminal os dados coletados pelo Application Insights.
# Uso: ./consultar-monitoramento.sh [minutos]   (padrão: últimos 30 minutos)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/variaveis.sh"

MINUTOS="${1:-30}"

az extension add --name log-analytics --upgrade --yes --only-show-errors

WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP_NAME \
  --workspace-name $LOG_WORKSPACE_NAME \
  --query customerId \
  --output tsv)

consultar() {
  echo
  echo ">> $1 (últimos $MINUTOS minutos)"
  az monitor log-analytics query \
    --workspace "$WORKSPACE_ID" \
    --analytics-query "$2" \
    --output table --only-show-errors
}

consultar "Requisições recebidas pelo app" \
  "AppRequests | where TimeGenerated > ago(${MINUTOS}m)
   | summarize requisicoes=count(), tempo_medio_ms=round(avg(DurationMs),1) by rota=Name, status=ResultCode
   | order by requisicoes desc"

consultar "Operações no banco Azure SQL" \
  "AppDependencies | where TimeGenerated > ago(${MINUTOS}m) and DependencyType == 'SQL'
   | extend comando=toupper(tostring(split(trim_start(' ', Data), ' ')[0]))
   | where comando in ('SELECT', 'INSERT', 'UPDATE', 'DELETE')
   | summarize chamadas=count(), tempo_medio_ms=round(avg(DurationMs),1) by comando"

consultar "Últimos comandos SQL executados" \
  "AppDependencies | where TimeGenerated > ago(${MINUTOS}m) and DependencyType == 'SQL'
   | top 5 by TimeGenerated desc
   | project hora=format_datetime(datetime_utc_to_local(TimeGenerated, 'America/Sao_Paulo'), 'HH:mm:ss'), sql=substring(Data, 0, 70)"
