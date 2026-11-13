---
name: aes-run-gate
description: Roda as checagens do projeto (lint, tipos, testes, build) e grava gate.md com GATE: PASS, FAIL ou SKIPPED. Use quando um prompt pedir o gate ou "rodar os testes" de uma issue já implementada. Não use para corrigir código nem para revisar.
---

# Run Gate

Verificação objetiva, determinística e somente leitura do que o `execute-task` entregou.

## Regras
- Sem perguntas, sem modo watch, sem `--fix`, sem editar código.
- Só grave `trabalhos/<repo>-issue-<n>/gate.md`.

## Passos
1. **Detectar** as checagens, nesta ordem:
   - `package.json`: scripts `lint`, `typecheck`, `test`, `build` (só os que existirem). Use `CI=1` e o gerenciador do lockfile.
   - Python: `pytest -q` se houver `pyproject.toml`/`requirements.txt` e pytest instalado.
   - Comandos citados em `AGENTS.md`/`CLAUDE.md`, se houver.
2. **Sem nenhuma checagem:** veredito `SKIPPED`.
3. **Rodar** uma a uma e anotar comando, exit code e as últimas ~30 linhas de saída de cada falha.
4. **Veredito:** `PASS` se todas saírem com 0; `FAIL` se alguma falhar.

## Formato do gate.md
```
GATE: PASS | FAIL | SKIPPED

## Checagens
| Comando | Resultado |
|---|---|
| npm run lint | ok |

## Falhas
<comando, exit code e trecho do log; vazio se PASS>
```
