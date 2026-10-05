#!/bin/bash
# Consulta as tabelas do banco para conferir a persistência após cada operação.
# Uso: ./consultar-banco.sh [clientes|transacoes]   (sem argumento: as duas)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/variaveis.sh"

if [ -z "$SQLCMDPASSWORD" ]; then
  read -s -p "Senha do administrador do SQL Server: " SQLCMDPASSWORD
  echo
  export SQLCMDPASSWORD
fi

if ! command -v sqlcmd > /dev/null 2>&1; then
  export PATH="$HOME/bin:$PATH"
fi

CLIENTES="SELECT CAST(id AS VARCHAR(4)) AS id, CAST(nome AS VARCHAR(25)) AS nome, cpf, CAST(email AS VARCHAR(30)) AS email, CAST(telefone AS VARCHAR(12)) AS telefone, CAST(FORMAT(data_cadastro, 'dd/MM/yyyy HH:mm') AS VARCHAR(16)) AS cadastro FROM clientes ORDER BY id;"
TRANSACOES="SELECT CAST(t.id AS VARCHAR(4)) AS id, CAST(c.nome AS VARCHAR(25)) AS cliente, CAST(t.tipo AS VARCHAR(13)) AS tipo, t.valor, CAST(t.descricao AS VARCHAR(30)) AS descricao, CAST(FORMAT(t.data_transacao, 'dd/MM/yyyy HH:mm') AS VARCHAR(16)) AS data FROM transacoes t INNER JOIN clientes c ON c.id = t.cliente_id ORDER BY t.id;"

case "$1" in
  clientes)   CONSULTA="$CLIENTES" ;;
  transacoes) CONSULTA="$TRANSACOES" ;;
  *)          CONSULTA="$CLIENTES PRINT ''; $TRANSACOES" ;;
esac

sqlcmd -S "$SQL_SERVER_NAME.database.windows.net" -d $SQL_DATABASE_NAME -U $SQL_ADMIN_USER \
  -s "|" -Q "SET NOCOUNT ON; $CONSULTA"
