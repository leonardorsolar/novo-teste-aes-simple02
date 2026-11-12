# Novo ciclo
Aprovação: stop_at_pr
Fases: Discover, Design, Build, Verify, Deliver, Operate

## Discover

### intake
- id: intake
- executa: agente intake
- grava: intake.md
- comandos: @intake issue #N
- aprovação: não

### prd
- id: prd
- executa: agente prd
- grava: prd.md
- comandos: @prd issue #3
- aprovação: não
- vereditos: APPROVED → @fim
