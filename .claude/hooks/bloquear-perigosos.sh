#!/usr/bin/env bash
# PreToolUse (Bash): bloqueia comandos irreversíveis ou que escrevem no GitHub.
# Lê o JSON do evento em stdin; exit 2 bloqueia e devolve a mensagem ao modelo.
input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null <<<"$input")
[ -z "$cmd" ] && exit 0

bloquear() { echo "Bloqueado: $1" >&2; exit 2; }

# rm recursivo e forçado, em qualquer ordem de flags (-rf, -fr, -r -f, --recursive --force)
if echo "$cmd" | grep -Eq '(^|[;&|[:space:]])rm[[:space:]]'; then
  r=0; f=0
  echo "$cmd" | grep -Eq '(^|[[:space:]])(-[a-zA-Z]*[rR][a-zA-Z]*|--recursive)([[:space:]]|$)' && r=1
  echo "$cmd" | grep -Eq '(^|[[:space:]])(-[a-zA-Z]*f[a-zA-Z]*|--force)([[:space:]]|$)' && f=1
  [ $r -eq 1 ] && [ $f -eq 1 ] && bloquear "rm recursivo e forçado"
fi

echo "$cmd" | grep -Eq 'git[[:space:]]+reset[[:space:]]+--hard' && bloquear "git reset --hard"

# Exceção: só os subagentes pr e merge (payload .agent_type) podem publicar. O que eles podem rodar
# é restrito por .claude/hooks/liberar-github.sh, registrado no frontmatter de cada um. Sem agent_type
# no payload (sessão principal, outros agentes ou versão sem o campo), vale o bloqueio de sempre.
agente=$(jq -r '.agent_type // empty' 2>/dev/null <<<"$input")
publica=0
case "$agente" in pr|merge) publica=1 ;; esac

if [ $publica -eq 0 ]; then
  echo "$cmd" | grep -Eq 'git[[:space:]]+push' && bloquear "git push não é permitido ao agente"
  echo "$cmd" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+(create|merge)' && bloquear "gh pr create/merge exige aprovação do usuário"
fi

# GitHub: só leitura (pr create/merge ficam de fora para pr e merge, tratados acima)
echo "$cmd" | grep -Eq 'gh[[:space:]]+(issue|pr)[[:space:]]+(comment|edit|close|reopen|delete|review|lock)' \
  && bloquear "gh issue/pr que escreve no GitHub exige aprovação do usuário"
echo "$cmd" | grep -Eq 'gh[[:space:]]+issue[[:space:]]+(create|merge)' \
  && bloquear "gh issue que escreve no GitHub exige aprovação do usuário"
echo "$cmd" | grep -Eq 'gh[[:space:]]+label' && bloquear "gh label"
if echo "$cmd" | grep -Eq 'gh[[:space:]]+api'; then
  echo "$cmd" | grep -Eiq '(-X|--method)[[:space:]]*(POST|PUT|PATCH|DELETE)' && bloquear "gh api não-GET"
  echo "$cmd" | grep -Eq '(^|[[:space:]])(-f|-F|--field|--raw-field|--input)([[:space:]=]|$)' && bloquear "gh api com corpo (vira POST)"
fi

exit 0
