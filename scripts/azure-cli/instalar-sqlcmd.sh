#!/bin/bash
# Garante o sqlcmd disponível. O Cloud Shell não traz o sqlcmd
# e apaga o ~/bin quando a sessão reinicia.
export PATH="$HOME/bin:$PATH"

if ! command -v sqlcmd > /dev/null 2>&1; then
  echo ">> sqlcmd não encontrado: instalando o go-sqlcmd (Microsoft) em ~/bin"
  mkdir -p "$HOME/bin"
  curl -sSL https://github.com/microsoft/go-sqlcmd/releases/latest/download/sqlcmd-linux-amd64.tar.bz2 \
    | tar -xj -C "$HOME/bin" sqlcmd
fi
