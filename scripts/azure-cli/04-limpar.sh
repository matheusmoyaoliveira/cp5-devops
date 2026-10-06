#!/bin/bash
# Remove TODOS os recursos do projeto (use só depois da correção do professor).
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/variaveis.sh"

read -p "Isso apaga o grupo $RESOURCE_GROUP_NAME e tudo dentro dele. Digite o nome do grupo para confirmar: " CONFIRMA
if [ "$CONFIRMA" != "$RESOURCE_GROUP_NAME" ]; then
  echo "Cancelado."
  exit 1
fi

az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait
echo ">> Exclusão iniciada (leva alguns minutos)."
