#!/usr/bin/env bash
# PreToolUse (Bash), registrado no frontmatter dos agentes pr e merge. Uso: liberar-github.sh pr|merge
# O bloquear-perigosos.sh deixa passar `git push` e `gh pr ...` desses dois agentes; aqui está a allow-list.
# Só os comandos de escrita no GitHub abaixo são permitidos; o resto segue as regras globais.
modo="$1"
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0

bloquear() { echo "Bloqueado ($modo): $1" >&2; exit 2; }
branch='feature/[A-Za-z0-9._-]+-issue-[0-9]+'

# só mexe nos comandos que escrevem no GitHub; leitura (git status/diff/log, gh pr view...) passa
echo "$cmd" | grep -Eq '(^|[^[:alnum:]_-])(git[[:space:]]+push|gh[[:space:]]+pr[[:space:]]+(create|merge|ready|edit|close|reopen|comment|review|lock))' || exit 0

# um comando por chamada: sem encadear, sem substituição
echo "$cmd" | grep -Eq '[;&|`<>]|\$\(' && bloquear "um comando por vez, sem ; & | < > crase nem \$()"
[ "$(printf '%s' "$cmd" | wc -l)" -gt 0 ] && bloquear "comando em várias linhas"
echo "$cmd" | grep -Eq '(--force|--force-with-lease|--admin|--no-verify|[[:space:]]-f([[:space:]]|$)|[[:space:]]\+)' && bloquear "flag proibida (force, admin ou no-verify)"

case "$modo" in
  pr)
    echo "$cmd" | grep -Eq "^git push (-u )?origin $branch$" && exit 0
    echo "$cmd" | grep -Eq '^gh pr create ' && echo "$cmd" | grep -q -- '--draft' && echo "$cmd" | grep -q -- '--body-file trabalhos/' && exit 0
    bloquear "o pr só pode: git push [-u] origin feature/<repo>-issue-<n> e gh pr create --draft --body-file trabalhos/..." ;;
  merge)
    echo "$cmd" | grep -Eq "^git push origin $branch$" && exit 0
    echo "$cmd" | grep -Eq '^gh pr ready [0-9]+$' && exit 0
    echo "$cmd" | grep -Eq '^gh pr merge [0-9]+ --squash( --delete-branch)?$' && exit 0
    bloquear "o merge só pode: git push origin feature/<repo>-issue-<n>, gh pr ready <n> e gh pr merge <n> --squash [--delete-branch]" ;;
  *) bloquear "modo desconhecido: $modo" ;;
esac
