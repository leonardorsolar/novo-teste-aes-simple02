#!/usr/bin/env bash
# PreToolUse (Write|Edit), registrado no frontmatter do agente execute-task:
# permite escrever código no projeto, mas protege configuração do agente,
# git, contexto, CLAUDE.md e os documentos já revisados das etapas anteriores.
f=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$f" ] && exit 0
raiz="${CLAUDE_PROJECT_DIR:-$(pwd)}"
case "$f" in
  /*) abs="$f" ;;
  *)  abs="$raiz/$f" ;;
esac
case "$abs" in
  *..*) echo "Bloqueado: caminho com .." >&2; exit 2 ;;
  "$raiz"/.claude/*|"$raiz"/.git/*|"$raiz"/contexto/*|"$raiz"/CLAUDE.md)
    echo "Bloqueado: o execute-task não altera $f" >&2; exit 2 ;;
  "$raiz"/trabalhos/*/intake.md|"$raiz"/trabalhos/*/prd*.md|"$raiz"/trabalhos/*/techspec*.md|"$raiz"/trabalhos/*/tasks*.md)
    echo "Bloqueado: documentos de etapas anteriores são somente leitura ($f)" >&2; exit 2 ;;
  "$raiz"/*) exit 0 ;;
esac
echo "Bloqueado: escrita fora do projeto ($f)" >&2
exit 2
