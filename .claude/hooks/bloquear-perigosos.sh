#!/bin/bash
# Hook PreToolUse: bloqueia comandos perigosos no terminal.
# O hook recebe os dados do evento em JSON pela entrada padrão.
cmd=$(jq -r '.tool_input.command // ""')
if echo "$cmd" | grep -qE 'rm -rf|git push --force'; then
  echo "Comando bloqueado pelo hook: peça aprovação ao usuário." >&2
  exit 2   # código 2 bloqueia a ação e devolve a mensagem ao agente
fi
exit 0
