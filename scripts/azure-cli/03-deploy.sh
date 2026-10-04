#!/bin/bash
# Compila a aplicação e publica o .jar no Web App com az webapp deploy.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/variaveis.sh"

echo ">> Compilando a aplicação (testes pulados: o teste padrão precisa do banco)"
cd "$SCRIPT_DIR/../../app"
chmod +x mvnw
./mvnw clean package -DskipTests

echo ">> Publicando o .jar no Web App $WEBAPP_NAME"
az webapp deploy \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $WEBAPP_NAME \
  --src-path target/dimdim-0.0.1-SNAPSHOT.jar \
  --type jar

echo ">> Deploy concluído: https://$WEBAPP_NAME.azurewebsites.net"
echo ">> No plano F1 a primeira carga pode levar 1-2 minutos."
