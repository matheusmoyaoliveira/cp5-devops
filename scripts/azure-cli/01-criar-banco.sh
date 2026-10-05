#!/bin/bash
# Cria o Resource Group, o Azure SQL Server, o banco db-dimdim,
# libera o firewall para os serviços da Azure e executa o DDL.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/variaveis.sh"

read -s -p "Defina a senha do administrador do SQL Server: " SQL_ADMIN_PASSWORD
echo

echo ">> Registrando o provedor Microsoft.Sql"
az provider register --namespace Microsoft.Sql --wait

echo ">> Criando o Resource Group $RESOURCE_GROUP_NAME em $LOCATION"
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location "$LOCATION"

echo ">> Criando o Azure SQL Server $SQL_SERVER_NAME"
az sql server create \
  --name $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location "$LOCATION" \
  --admin-user $SQL_ADMIN_USER \
  --admin-password "$SQL_ADMIN_PASSWORD" \
  --enable-public-network true

echo ">> Criando o banco $SQL_DATABASE_NAME (camada Basic)"
az sql db create \
  --resource-group $RESOURCE_GROUP_NAME \
  --server $SQL_SERVER_NAME \
  --name $SQL_DATABASE_NAME \
  --service-objective Basic \
  --backup-storage-redundancy Local \
  --zone-redundant false

echo ">> Liberando o firewall para os serviços da Azure (Web App e Cloud Shell)"
az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP_NAME \
  --server $SQL_SERVER_NAME \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

if ! command -v sqlcmd > /dev/null 2>&1; then
  echo ">> sqlcmd não encontrado: instalando o go-sqlcmd (Microsoft) em ~/bin"
  mkdir -p "$HOME/bin"
  curl -sSL https://github.com/microsoft/go-sqlcmd/releases/latest/download/sqlcmd-linux-amd64.tar.bz2 \
    | tar -xj -C "$HOME/bin" sqlcmd
  export PATH="$HOME/bin:$PATH"
fi

echo ">> Executando o DDL (scripts/sql/ddl-dimdim.sql)"
export SQLCMDPASSWORD="$SQL_ADMIN_PASSWORD"
sqlcmd \
  -S "$SQL_SERVER_NAME.database.windows.net" \
  -d $SQL_DATABASE_NAME \
  -U $SQL_ADMIN_USER \
  -i "$SCRIPT_DIR/../sql/ddl-dimdim.sql"
unset SQLCMDPASSWORD

echo ">> Banco pronto: $SQL_SERVER_NAME.database.windows.net / $SQL_DATABASE_NAME"
