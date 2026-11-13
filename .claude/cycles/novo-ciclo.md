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
