#!/usr/bin/env bash
# Merge: atualiza a branch com a base, roda o gate de novo e faz o merge pelo GitHub.
# Quem roda: factory/bin/job run <job>, na worktree do job, com JOB_ID, BRANCH, BASE, PR,
# MERGE_METHOD e REPO no ambiente. Saída 0 = MERGED; outra = FAIL (o job vai para um humano).
# Nunca faz merge local na base, nunca --force, nunca --admin.
set -euo pipefail

[ -n "${PR:-}" ] || { echo "O job não tem PR; a etapa pr precisa rodar antes." >&2; exit 1; }

state=$(gh pr view "$PR" --json state -q .state)
if [ "$state" = "MERGED" ]; then echo "PR #$PR já estava mergeado."; exit 0; fi

git fetch origin "$BASE"
if ! git merge --no-edit "origin/$BASE"; then
  git merge --abort || true
  echo "A branch tem conflito com $BASE." >&2
  exit 1
fi
"$REPO/factory/bin/gate" "$JOB_ID" --merge
git push origin "$BRANCH"
if [ "$(gh pr view "$PR" --json isDraft -q .isDraft)" = "true" ]; then gh pr ready "$PR"; fi
gh pr merge "$PR" "--$MERGE_METHOD"
git push origin --delete "$BRANCH" >/dev/null 2>&1 || true   # o GitHub pode já ter apagado
echo "MERGED"
