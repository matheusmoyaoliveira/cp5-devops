#!/bin/bash
# ------------------------------------------------------------------
# Projeto DimDim - variáveis compartilhadas por todos os scripts
# Regiões permitidas pela policy da conta:
#   eastus, eastus2, centralus, northcentralus, mexicocentral
# ------------------------------------------------------------------

RM="rm563403"
LOCATION="eastus2"

RESOURCE_GROUP_NAME="rg-dimdim"

# Banco (Azure SQL - PaaS)
SQL_SERVER_NAME="sql-dimdim-$RM"
SQL_DATABASE_NAME="db-dimdim"
SQL_ADMIN_USER="user-dimdim"

# Aplicação (App Service)
APP_SERVICE_PLAN="plan-dimdim"
WEBAPP_NAME="dimdim-$RM"
RUNTIME="JAVA:17-java17"

# Monitoramento
LOG_WORKSPACE_NAME="log-dimdim"
APP_INSIGHTS_NAME="ai-dimdim"
