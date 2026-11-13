#!/usr/bin/env bash
# PreToolUse (Write|Edit), registrado no frontmatter do agente intake:
# só permite gravar dentro de trabalhos/ do projeto.
f=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$f" ] && exit 0
raiz="${CLAUDE_PROJECT_DIR:-$(pwd)}"
case "$f" in
  /*) abs="$f" ;;
  *)  abs="$raiz/$f" ;;
esac
case "$abs" in
  "$raiz"/trabalhos/*..*|*/../*) echo "Bloqueado: caminho com .." >&2; exit 2 ;;
  "$raiz"/trabalhos/*) exit 0 ;;
esac
echo "Bloqueado: o intake só grava em trabalhos/ (tentou: $f)" >&2
exit 2
