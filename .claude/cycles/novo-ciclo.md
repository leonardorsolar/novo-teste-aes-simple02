# Ciclo: novo-ciclo
Aprovação: stop_at_pr
Fases: Fase: Discovery, Design, Build, Verify, Deliver

## Fase: Discovery

### Intake
- id: intake
- executa: agente intake
- lê: issue.md
- grava: intake.md
- comandos: @intake triar a <issue#N>
- aprovação: não
- vereditos: ACCEPT → @next; NEEDS-INFO → @wait-author; REJECT → @rejected

### PRD
- id: prd
- executa: agente prd (skill aes-create-prd)
- lê: issue.md, intake.md
- grava: prd.md
- comandos: @prd crie o PRD da <issue#N>
- aprovação: não
- vereditos: DONE → @next; BLOCKED → @human

## Design

### Techspec
- id: techspec
- executa: agente doc-writer-techspec (skill aes-create-techspec)
- lê: issue.md, intake.md, prd.md
- grava: techspec.md
- comandos: @doc-writer-techspec crie o techspec da <issue#N>
- aprovação: não
- vereditos: DONE → @next; BLOCKED → @human

### Tasks
- id: tasks
- executa: agente doc-writer-tasks (skill aes-create-tasks)
- lê: issue.md, intake.md, prd.md, techspec.md
- grava: tasks.md
- comandos: @doc-writer-tasks crie as tasks da <issue#N>
- aprovação: não
- vereditos: DONE → @next; BLOCKED → @human

## Build

### Execute Task
- id: execute-task
- executa: agente execute-task (skill aes-execute-task)
- lê: issue.md, intake.md, prd.md, techspec.md, tasks.md
- grava: execute-task.md
- comandos: @execute-task implemente a <issue#N>
- aprovação: não
- vereditos: DONE → @next; BLOCKED → @human

## Verify

### Gate
- id: gate
- executa: agente gate (skill aes-run-gate)
- lê: execute-task.md
- grava: gate.md
- comandos: @gate rodar os testes (lint, tipos, testes, build) da <issue#N>
- aprovação: não
- vereditos: PASS → @next; SKIPPED → @next; FAIL → execute-task

### Review Code
- id: review-code
- executa: agente reviewer-code
- lê: issue.md, prd.md, techspec.md, tasks.md, execute-task.md, gate.md
- grava: review-code.md
- comandos: @reviewer-code revise o código da <issue#N>
- aprovação: não
- vereditos: PASS → @next; CHANGES → execute-task

### Review Security
- id: review-security
- executa: agente reviewer-security
- lê: issue.md, prd.md, techspec.md, tasks.md, execute-task.md, gate.md
- grava: review-security.md
- comandos: @reviewer-security revise a segurança da <issue#N>
- aprovação: não
- vereditos: PASS → @next; CHANGES → execute-task

### Review UI
- id: review-ui
- executa: agente reviewer-ui
- lê: issue.md, prd.md, techspec.md, tasks.md, execute-task.md, gate.md
- grava: review-ui.md
- comandos: @reviewer-ui revise a UI da <issue#N>
- aprovação: não
- vereditos: PASS → @next; CHANGES → execute-task

### Review UX
- id: review-ux
- executa: agente reviewer-ux
- lê: issue.md, prd.md, techspec.md, tasks.md, execute-task.md, gate.md
- grava: review-ux.md
- comandos: @reviewer-ux revise a UX da <issue#N>
- aprovação: não
- vereditos: PASS → @next; CHANGES → execute-task

## Deliver

### PR
- id: pr
- executa: agente pr
- lê: issue.md, prd.md, techspec.md, tasks.md, execute-task.md, gate.md, review-code.md, review-security.md, review-ui.md, review-ux.md
- grava: pr.md
- comandos: @pr abra o PR da <issue#N>
- aprovação: não
- vereditos: PASS → @next; FAIL → @human

### Approve
- id: approve
- executa: agente approver
- lê: issue.md, prd.md, techspec.md, tasks.md, execute-task.md, gate.md, review-code.md, review-security.md, review-ui.md, review-ux.md, pr.md
- grava: decision.md
- comandos: @approver decida a aprovação da <issue#N>
- aprovação: não
- vereditos: APPROVE → @next; ESCALATE → @human

### Merge
- id: merge
- executa: agente merge
- lê: pr.md, gate.md, decision.md
- grava: merge.md
- comandos: @merge faça o merge da <issue#N>
- aprovação: sim (confirma antes: ação pública e irreversível)
- vereditos: MERGED → @next; FAIL → @human
