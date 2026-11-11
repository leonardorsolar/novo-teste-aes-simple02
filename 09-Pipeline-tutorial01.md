# Tutorial 01 — Primeira tarefa com o ciclo Fábrica v2

Do zero até a primeira tarefa virar um PR, usando o ciclo **Fábrica v2**, o padrão da fábrica (8 cards). Para trabalho maior, com PRD, protótipo e techspec, veja o [Tutorial 02 — Ciclo SDD](09-Pipeline-tutorial02.md). Detalhes técnicos em [09-Pipeline.md](09-Pipeline.md).

**Ideia central:** a tela configura, o Claude Code executa. Tudo o que você escolhe na tela vai para arquivos dentro do seu projeto (`factory/pipeline.yaml` e `factory/tasks/<KEY>.yaml`), e o Claude Code lê esses arquivos.

## Antes de começar
Você precisa de:
- um repositório git com `origin` no GitHub;
- `gh` logado, com permissão de push e de criar rótulos;
- Claude Code 2.1.257 ou mais recente e `python3` 3.10 ou mais recente.

Confira tudo de uma vez, na raiz do projeto:

```bash
git remote -v && gh auth status && claude --version && python3 --version
```

Na tela, conecte duas coisas em **Preferences**: a conta do GitHub (para criar issues) e a pasta do projeto (**Select project folder**), com permissão de escrita.

## 1. Instalar a fábrica no projeto
1. Abra **Pipeline 2** no menu lateral.
2. Clique em **Instalar fábrica no projeto**. A tela copia `factory/` e `.claude/` para o projeto **sem sobrescrever** nada que já exista.
3. O navegador não consegue dar permissão de execução. No terminal, na raiz do projeto:

   ```bash
   chmod +x factory/bin/* factory/scripts/*.sh && factory/bin/factory validate
   ```

   O esperado é uma linha começando com `ok:`.

> Atalho: o passo a passo da Pipeline 2 tem um prompt pronto para o Claude Code fazer os passos 2 a 8 (gate, ajustes, rótulos, AGENTS.md) por você.

## 2. Ajustar ao seu projeto
Abra **Configurações** (ícone de engrenagem, `#/config`):

| Aba | O que conferir |
|---|---|
| **Básica** | Branch base (ex.: `main`); **Jobs ao mesmo tempo**: comece com `1` até confiar na fábrica; rodadas antes de chamar um humano; ciclo padrão |
| **Etapas** | Quem executa cada etapa (agente, skill, script, humano) e o modelo |
| **Agentes, skills, prompts e scripts** | Edite `factory/scripts/gate.sh` com os checks reais do projeto |

Clique em **Salvar alterações**. Erros de validação aparecem no topo e impedem salvar.

O `gate.sh` precisa rodar lint, typecheck, testes e build, sem `--fix` e sem perguntar nada, e sair com erro se algo falhar. Teste-o:

```bash
bash factory/scripts/gate.sh; echo "saiu com $?"
```

Se ele falhar no projeto limpo, a fábrica nunca vai aprovar nenhum job: corrija o script antes de seguir.

Depois, crie os rótulos no GitHub (uma vez por repositório):

```bash
gh label create factory --color 5319E7 --description "Build this with the software factory"
gh label create factory:needs-info --color FBCA04 --description "The factory asked the author a question"
gh label create factory:needs-human --color D93F0B --description "The factory needs a human decision on the PR"
```

Por fim, faça commit de `factory/` e `.claude/`, adicione `/factory/jobs/`, `/.worktrees/` e `__pycache__/` ao `.gitignore` e dê push: os jobs partem de `origin/<branch base>`.

## 3. Criar uma tarefa e escolher a pipeline
1. Vá em **Work** (página Tasks) e clique em criar tarefa.
2. Escreva o título e a descrição e clique em **Criar tarefa**.
3. Abre o **seletor de pipeline**. Escolha:
   - **Ciclo**: **Fábrica v2 (revisores roteados)**. O perfil "Fábrica v2" é marcado sozinho (8 cards).
   - **Modo de aprovação**: o ciclo v2 vem em **Automático** (o approver decide e faz o merge). Na primeira vez, troque para **Para no PR**: a fábrica para no PR e o merge é seu. **Manual** pausa depois de cada card.
4. Configure cada card como na seção [Agentes de cada card](#agentes-de-cada-card-ciclo-fábrica-v2) abaixo.
5. Confirme. A tela grava `factory/tasks/WORK-1.yaml` no projeto.

Outros ciclos: **Rápido** (bug ou mudança pequena, sem spec), **Ciclo SDD** ([Tutorial 02](09-Pipeline-tutorial02.md)), **AI-Native SDLC**, **SDLC completo**, ou **Automático** (o intake escolhe o perfil).

### Agentes de cada card (ciclo Fábrica v2)
Clique no card no desenho. O painel **Configuração deste bloco** tem três campos: **Agente**, **Skill** e **Prompt**. Use **+ Escolher ou cadastrar agente** (ou skill, ou prompt) e depois **Usar neste bloco**.

| # | Card | Fase | Agente | Skill | Prompt | Modelo | Grava | Vereditos |
|---|---|---|---|---|---|---|---|---|
| 1 | **Intake** | Discover | `intake` | — | — | fable | `intake.md` | `ACCEPT` → Spec · `NEEDS-INFO` → pergunta ao autor · `REJECT` → encerra |
| 2 | **Spec** | Design | `spec-writer` | — | — | opus | `spec.md` | `DONE` → Build · `BLOCKED` → humano |
| 3 | **Build** | Build | `builder` | — | — | opus | `build.md` | `READY` → Gate · `BLOCKED` → humano |
| 4 | **Gate** | Verify | *script* `factory/bin/gate` (roda `factory/scripts/gate.sh`) | — | — | — | `round-<n>/checks.md` | `PASS` → revisão · `FAIL` → volta ao Build |
| 5 | **Code review** | Verify | `reviewer-code` | — | — | haiku (risco baixo) / sonnet (médio, alto) | `round-<n>/review-code.md` | `PASS` → PR · `CHANGES` → volta ao Build |
| 6 | **PR** | Deliver | *script* `factory/scripts/pr.sh` | — | — | — | `pr.md` | `PASS` → Approve · `FAIL` → humano |
| 7 | **Approve** | Deliver | `approver` | — | — | opus | `decision.md` | `APPROVE` → Merge · `ESCALATE` → humano |
| 8 | **Merge** | Deliver | *script* `factory/scripts/merge.sh` | — | — | — | `merge.md` | `MERGED` → fim · `FAIL` → humano |

Regras:
- **Cards com agente** (1, 2, 3, 5, 7): adicione só o agente da tabela. Deixe Skill e Prompt vazios. Se quiser orientar esta tarefa, escreva em **Instruções extras** (ex.: no Build, "não mexa no módulo de pagamentos").
- **Cards de script** (4, 6, 8): não recebem agente. O painel mostra o script, que vale para todas as tarefas; edite-o em **Configurações → Agentes, skills, prompts e scripts**.
- **Modelo**: vazio usa o `model:` do agente (coluna Modelo). No Code review, quem escolhe é o roteamento, pelo `RISK` do intake.
- **Revisores roteados**: o v2 liga sozinho, depois do intake, os cards que a issue pede, todos no mesmo grupo e em paralelo com o Code review. Não precisa adicioná-los à mão:

  | Card ligado pelo roteamento | Quando (`SURFACES` do intake) | Agente | Modelo | Grava |
  |---|---|---|---|---|
  | **UX review** | `ui` | `reviewer-ux` | sonnet | `round-<n>/review-ux.md` |
  | **UI review** | `ui` | `reviewer-ui` | haiku | `round-<n>/review-ui.md` |
  | **Security review** | `security` | `reviewer-security` | opus | `round-<n>/review-security.md` |

- Se o card já mostra o executor certo em **Quem executa** (vem do `pipeline.yaml`), adicionar o mesmo agente no painel é opcional: sem escolha no card, a etapa usa o executor do arquivo. Adicionar deixa a escolha gravada em `factory/tasks/<KEY>.yaml`.
- Para conferir a ordem no terminal: `factory/bin/factory plan v2 --surfaces ui,security --risk high`.

Para mudar depois: abra a tarefa e clique em **Editar**, ao lado da etiqueta da pipeline.

## 4. Criar a issue no GitHub
A fábrica só trabalha em issues com o rótulo `factory`. No modal da tarefa, clique em **Criar issue no GitHub**. A issue é criada com o rótulo, e o número dela vai para o arquivo da tarefa, que é como a fábrica encontra as suas escolhas.

Para o primeiro teste, use algo bem pequeno. Também dá pelo terminal:

```bash
gh issue create --label factory --title "Add a subtract function" --body "Add subtract(a, b) next to add and cover it with a test."
```

## 5. Rodar no Claude Code
Abra o Claude Code na raiz do projeto e digite:

```
/factory run
```

| Comando | Faz |
|---|---|
| `/factory run` | Pega todas as issues abertas com `factory`, até o limite de jobs ao mesmo tempo |
| `/factory run 12` | Roda só a issue #12 |
| `/factory <qualquer coisa>` | Conversa com a fábrica: status, por que um job parou, feedback, nova feature |

## 6. Acompanhar
Deixe a **Pipeline 2** aberta. Quando aparece `factory/jobs/`, os cards andam sozinhos pelas colunas (Discover → Design → Build → Verify → Deliver), com rodada, vereditos dos revisores, PR e custo. Clique num card para ler os arquivos do job (`intake.md`, `spec.md`, `round-1/checks.md`…).

No terminal, `factory/bin/job summary` mostra a mesma coisa em tabela.

## 7. Quando a fábrica para e chama você
| Situação | Coluna / rótulo | O que fazer |
|---|---|---|
| Pausada pelo modo de aprovação (ex.: Para no PR) | job em `wait` | Revise o PR. Para continuar: merge no GitHub ou `factory/bin/job approve <job>` |
| O intake fez uma pergunta ao autor | `factory:needs-info` | Responda na issue e diga `/factory` que respondeu (ou `factory/bin/job resume <job>`) |
| Rodadas esgotadas ou decisão humana | **Needs human** · `factory:needs-human` | Leia `escalation.md`; mande feedback: `/factory no job 12, use a tabela X em vez de Y` |
| Etapa humana (`human: true`) | `wait` | `factory/bin/job answer <job> <VEREDITO>` com a resposta no stdin |
| Desistir | — | `/factory rejeite o job 12 porque …` (fecha o PR e remove os rótulos) |

## 8. Mudar a fábrica
- **Pela tela**: Configurações → aba correspondente → **Salvar alterações**.
- **Arquivo inteiro**: botão **YAML avançado**.
- **À mão**: edite `factory/pipeline.yaml` e confira:

  ```bash
  factory/bin/factory validate     # erros e avisos
  factory/bin/factory plan rapido  # ordem efetiva das etapas de um ciclo
  ```

- **Pelo Claude**: `/factory troque o spec do ciclo v2 para a skill sdlc-spec`.

Jobs já em andamento não mudam: cada um guardou a própria cópia em `factory/jobs/<id>/pipeline.lock.json`. A mudança vale para os próximos.

### Exemplos rápidos
Desligar o gate no perfil Bug simples (tire `gate` da lista; o code review passa a vir direto do build):

```yaml
profiles:
  bug: { label: Bug simples, steps: [intake, build, review_code, pr, approve, merge] }
```

Criar um ciclo próprio:

```yaml
cycles:
  meu-ciclo:
    label: Feature com spec por skill
    profile: feature
    approval: stop_at_pr
    override:
      spec: { run: { skill: sdlc-spec, model: opus } }
```

## Problemas comuns
| Sintoma | Causa provável |
|---|---|
| Configurações diz "você está vendo o padrão" | O projeto ainda não tem `factory/pipeline.yaml`: instale a fábrica ou salve |
| "falta permissão de escrita" | Clique em **Permitir acesso** (o navegador pede no clique) |
| `Permission denied` ao rodar `factory/bin/...` | Faltou o `chmod +x` do passo 1 |
| "O GitHub recusou a issue" | O rótulo `factory` não existe no repositório |
| `job create` recusa a issue | A issue não tem o rótulo `factory` |
| Todo job volta do gate com FAIL | `gate.sh` quebrado no projeto limpo (teste com `bash factory/scripts/gate.sh`) |
| A escolha da tela foi ignorada | A tarefa não tinha issue quando o job foi criado, ou a pasta não estava conectada ao salvar (não há `factory/tasks/<KEY>.yaml`) |
