---
name: criar-agente
description: Use quando o usuário pedir para criar, desenhar ou melhorar um agente (subagente) completo: workspace, arquivo do agente, skill/playbook, memória, hooks e automação.
---

# Criar Agente Completo

Guia o usuário na criação de um agente completo, um nível por vez. Serve para qualquer tipo de agente (requisitos, arquitetura, implementação, testes, conteúdo, etc.).

Um agente completo tem 5 partes: **cérebro** (modelo), **contexto** (o que ele sabe), **tarefa** (objetivo), **regras** (como agir e o que nunca fazer) e **ferramentas** (o que pode usar). Todo arquivo que você gerar deve deixar essas 5 partes claras.

## Onde instalar e onde escrever

Esta skill é instalada **no projeto de destino** (`<projeto>/.claude/skills/criar-agente/`) e cria tudo **nesse projeto**, nunca no repositório onde o kit foi montado.

- **Raiz do workspace = raiz do projeto de destino** (a pasta que contém o `.claude/` onde esta skill está). Todos os caminhos deste documento são relativos a ela.
- No início, confirme a raiz com o usuário (ex.: `/home/usuario/projetos/meu-projeto`) e use `pwd` e `ls -a` para checar. Se a sessão estiver aberta em outra pasta, pare e peça ao usuário para abrir o Claude Code na raiz do projeto, ou confirme o caminho absoluto e use-o em todos os arquivos criados.
- O projeto de destino pode já ter `.claude/` (agentes, skills, hooks, `settings.json`). **Nunca sobrescreva:** liste o que existe, leia, e só acrescente ou mescle. Conflito de nome (agente, skill ou hook com o mesmo nome): pergunte antes.
- Não toque em arquivos do projeto fora das pastas desta estrutura (código-fonte, `.gitignore`, etc.) sem aprovação.

## Como conduzir

- Trabalhe um nível por vez e confirme com o usuário antes de avançar.
- Você escreve os arquivos; o usuário só responde perguntas e aprova.
- Se um arquivo já existir, leia e atualize em vez de sobrescrever.
- Use nomes em kebab-case (ex.: `revisor-de-codigo`).
- Responda no idioma do usuário.

## Estrutura final

Esta é a estrutura completa que a skill entrega, no projeto de destino:

```
<projeto>/
├── CLAUDE.md                          # guia lido em toda sessão: onde está cada coisa, lista de agentes, regras gerais
├── LEIA-ME.md                         # (opcional) como instalar, testar e acionar; só se o usuário quiser
├── contexto/
│   └── contexto.md                    # negócio/projeto, público, critérios, padrões, exemplos
├── trabalhos/                         # saídas dos agentes
│   ├── STATUS.md                      # uma linha por tarefa: pendente → feito → aprovado
│   └── <item>/<entrega>.md            # uma pasta por tarefa (ex.: <repo>-issue-<n>/intake.md)
├── docs/
│   └── <agente>-diagrama.excalidraw   # diagrama para apresentar o agente (opcional, ver Encerramento)
└── .claude/
    ├── agents/<agente>.md             # o agente
    ├── memory/<agente>-memoria.md     # lições aprendidas
    ├── settings.json                  # registro dos hooks (mesclar, nunca sobrescrever)
    ├── hooks/<nome>.sh                # scripts dos hooks (ex.: bloquear-perigosos.sh)
    └── skills/
        ├── criar-agente/              # esta skill
        ├── excalidraw/                # gera o diagrama final
        └── <skill>/                   # playbook do agente criado
            ├── SKILL.md
            ├── references/            # documentos de apoio (opcional)
            ├── assets/                # modelos e arquivos usados na saída (opcional)
            └── scripts/               # scripts executáveis (opcional)
```

Mapa de qual nível cria o quê:

| Nível | Cria |
|---|---|
| 0 | `CLAUDE.md`, `contexto/contexto.md`, `trabalhos/` e `trabalhos/STATUS.md` |
| 1 | `.claude/agents/<agente>.md` |
| 2 | `.claude/skills/<skill>/SKILL.md` (+ `references/`, `assets/`, `scripts/` se houver conteúdo) |
| 3 | `.claude/memory/<agente>-memoria.md` |
| 4 | caixa de entrada e rotina (opcional) |
| 5 | `.claude/hooks/*.sh` e o bloco `hooks` de `.claude/settings.json` |
| Encerramento | `docs/<agente>-diagrama.excalidraw` |

## Nível 0: Workspace

1. Confirme a pasta de trabalho e leia o que já existe nela (arquivos de referência, exemplos, site ou repositório indicado).
2. Faça de 3 a 5 perguntas sobre o que não der para descobrir sozinho.
3. Crie `contexto/contexto.md` com: o que é o projeto, para quem, padrões e estilo, exemplos de referência.
4. Crie ou atualize `CLAUDE.md` com: resumo do workspace, onde está cada coisa (espelhando a estrutura final acima), a lista de agentes (vazia por enquanto) e as regras gerais. Se o projeto já tiver um `CLAUDE.md`, preserve o conteúdo e acrescente uma seção nova (ex.: `## Agentes`), sem reescrever o resto.
5. Crie a pasta `trabalhos/` com `trabalhos/STATUS.md` (modelo abaixo), onde os agentes gravam as entregas e o andamento.
6. Teste: peça ao usuário para abrir uma sessão nova e fazer uma tarefa simples, para ver se o contexto está sendo usado.

Modelo do `trabalhos/STATUS.md`:

```markdown
# Status dos trabalhos

Status: `pendente` (na caixa de entrada, sem entrega), `feito` (entrega gravada pelo agente), `aprovado` (só o usuário marca).

| Item | Título | Status | Resultado | Data |
|---|---|---|---|---|
```

## Nível 1: Agente

1. Entreviste o usuário (uma rodada, perguntas numeradas):
   - Qual é o trabalho do agente, em uma frase?
   - O que ele recebe como entrada e o que entrega como saída (formato e local)?
   - Quando ele deve ser acionado?
   - O que ele nunca pode fazer?
   - Quais ferramentas ele precisa? (só leitura, edição, terminal, web, conectores)
   - Em que pontos deve parar e pedir aprovação?
2. Resuma as 5 partes e confirme o nome com o usuário.
3. Crie `.claude/agents/<agente>.md` usando o modelo abaixo.
4. Teste: peça ao usuário para chamar o agente pelo nome (`@<agente>`) em uma tarefa real. Ajuste o arquivo conforme o resultado; a primeira versão raramente é a final.

Modelo do agente:

```markdown
---
name: <agente>
description: <o que faz e quando delegar para ele, em 1 ou 2 frases específicas>
tools: Read, Grep, Glob        # liste só o necessário; sem este campo ele herda todas
model: inherit                 # ou haiku para rotina, opus para tarefas difíceis
---

Você é <papel>. Seu objetivo é <tarefa>.

## Antes de começar
- Leia `contexto/contexto.md`.
- Leia `.claude/memory/<agente>-memoria.md` e aplique as lições.

## Processo
1. <passo>
2. <passo>
3. <passo>

## Entrega
- Formato: <formato>
- Local: `trabalhos/<item>/<entrega>.md`
- Depois de gravar, atualize `trabalhos/STATUS.md` (uma linha por item; `pendente` → `feito`; nunca marque `aprovado`).

## Regras
- Nunca edite arquivos além da entrega e do `trabalhos/STATUS.md`.
- Nunca <restrição>.
- Se a tarefa for ambígua, faça perguntas numeradas e espere a resposta.
- Pare e peça aprovação antes de <ação de risco>.
```

Regras para preencher:
- `name` e `description` são obrigatórios. A `description` decide quando o agente é acionado, então seja específico.
- Restrinja `tools`: agentes de análise ou planejamento só leem e escrevem documentos; só quem implementa precisa de edição de código e terminal.
- Uma responsabilidade por agente. Se o trabalho tiver duas fases, crie dois agentes.

## Nível 2: Skill (playbook)

Crie uma skill quando o agente acertar o trabalho, mas variar de uma execução para outra.

1. Entreviste o usuário sobre a última entrega do agente: o que deve se repetir sempre, o que mudar, qual é o critério de "bom".
2. Crie `.claude/skills/<skill>/SKILL.md` usando o modelo abaixo.
3. Só crie `references/`, `assets/` e `scripts/` se houver conteúdo para eles.
4. Atribua a skill ao agente: adicione `skills: <skill>` no frontmatter do agente e, no processo dele, a instrução de seguir a skill.
5. Atualize `CLAUDE.md` dizendo em que pedidos usar o agente.
6. Teste com `/<skill>` e depois com uma tarefa nova entregue ao agente.

Modelo da skill:

```markdown
---
name: <skill>
description: <o que a skill faz e quando usar>
---

# <Título>

## Fluxo
1. <passo>
2. <passo>
3. <passo>

## Checklist de qualidade
- [ ] <critério verificável>
- [ ] <critério verificável>

## Formato de saída
<estrutura esperada>

## Erros a evitar
- <erro comum>
```

## Nível 3: Memória

Sem memória, toda sessão começa do zero e o usuário repete o mesmo feedback.

1. Crie `.claude/memory/<agente>-memoria.md` com o modelo abaixo.
2. Confirme que o arquivo do agente manda ler a memória antes de cada tarefa.
3. Adicione ao agente a regra: "Ao receber feedback, corrija a entrega e registre na memória apenas o que vale para trabalhos futuros. Não registre ajustes pontuais."
4. Teste: o usuário dá um feedback, você confere se a lição foi gravada, e roda uma tarefa diferente para ver se a lição foi aplicada.

Modelo da memória:

```markdown
# Memória: <agente>

Lições que valem para todos os trabalhos futuros. Uma por linha.

## Fazer sempre
- <lição>

## Nunca fazer
- <lição>
```

Quando a memória crescer, agrupe lições parecidas; se uma lição virar regra fixa, mova para a skill.

## Nível 4: Autonomia (opcional)

Só proponha depois que os níveis 0 a 3 estiverem funcionando. Na caixa de entrada, a saída vai para `trabalhos/` e o andamento para `trabalhos/STATUS.md`.

1. Conecte as ferramentas externas de que o agente precisa (ex.: Notion, GitHub) e diga ao agente que pode usá-las.
2. Versione o workspace em um repositório Git privado, para o agente poder rodar na nuvem.
3. Defina uma "caixa de entrada" (pasta, página ou quadro) onde o usuário deixa tarefas com status: pendente, feito, aprovado.
4. Crie uma tarefa agendada com instrução completa: verificar a caixa de entrada, executar com o agente, marcar como feito e relatar o resultado.
5. Mantenha revisão humana: o agente entrega rascunhos; o usuário aprova.

## Nível 5: Hooks (recomendado)

Hook é um comando que roda sozinho em um evento do Claude Code. Use para o que precisa acontecer sempre, sem depender do agente lembrar. Regra prática: instrução vai no agente ou na skill; garantia vai no hook.

| Evento | Quando roda | Uso típico |
|---|---|---|
| `PreToolUse` | Antes de uma ferramenta | Bloquear comandos perigosos |
| `PostToolUse` | Depois de uma ferramenta | Formatar, rodar lint ou testes após edição |
| `SubagentStop` | Quando um agente termina | Conferir a entrega, indicar o próximo agente |
| `SessionStart` | Ao abrir a sessão | Carregar contexto extra |

1. Pergunte ao usuário o que deve ser garantido (bloquear, validar ou encadear) e escolha o evento.
2. Crie o script em `.claude/hooks/<nome>.sh` e torne-o executável (`chmod +x`).
3. Registre em `.claude/settings.json`. Se o arquivo já existir (é comum em projeto existente, com hooks de outras ferramentas), leia-o e **mescle**: acrescente o novo item no array do evento (ex.: `PreToolUse`), preservando tudo o que já estiver lá, inclusive hooks de outros eventos. Mostre o resultado ao usuário antes de gravar.
4. Valide o JSON (ex.: `jq . .claude/settings.json`) e teste provocando o evento.
5. Versione `.claude/hooks/` e `settings.json` junto com o projeto.

Modelo de registro:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/bloquear-perigosos.sh" }
        ]
      }
    ]
  }
}
```

Modelo de script (`bloquear-perigosos.sh`):

```bash
#!/bin/bash
# O hook recebe os dados do evento em JSON pela entrada padrão.
cmd=$(jq -r '.tool_input.command // ""')
if echo "$cmd" | grep -qE 'rm -rf|git push --force'; then
  echo "Comando bloqueado pelo hook: peça aprovação ao usuário." >&2
  exit 2   # código 2 bloqueia a ação e devolve a mensagem ao agente
fi
exit 0
```

Regras:
- `matcher` filtra pela ferramenta (ex.: `Bash`, `Edit|Write`).
- Hooks rodam com as permissões do usuário: mantenha os scripts curtos, mostre-os ao usuário antes de ativar e nunca coloque segredos neles.
- Um hook só para aquele agente pode ir no campo `hooks` do frontmatter do agente, em vez do `settings.json`.
- Antes de escrever um hook de evento que você não conhece bem, consulte a documentação de hooks do Claude Code para conferir o formato de entrada e saída.

## Vários agentes em sequência

Para um agente por fase (ex.: requisitos, arquitetura, implementação, testes):

- Repita os níveis 1 a 3 para cada agente.
- A passagem entre agentes é feita por arquivos: cada um lê a entrega do anterior e grava a sua.
- Registre o status de cada tarefa em `trabalhos/STATUS.md` (ex.: `PRONTO_PARA_ARQUITETURA`, `PRONTO_PARA_IMPLEMENTAR`, `CONCLUIDO`, além de `aprovado` marcado só pelo usuário).
- Coloque aprovação humana antes de implementar e antes de publicar.
- Um hook `SubagentStop` pode ler o status e indicar o próximo agente.
- Liste todos os agentes e a ordem deles no `CLAUDE.md`.

## Checklist final

- [ ] Tudo foi criado no projeto de destino, sem sobrescrever arquivos que já existiam
- [ ] `CLAUDE.md`, `contexto/contexto.md`, `trabalhos/` e `trabalhos/STATUS.md` existem e foram testados em sessão nova
- [ ] O agente tem `name`, `description` específica, `tools` restritas e as 5 partes
- [ ] A skill tem fluxo, checklist e formato de saída, e está atribuída ao agente
- [ ] A memória existe, é lida antes de cada tarefa e recebeu ao menos uma lição
- [ ] O agente foi testado em pelo menos duas tarefas diferentes
- [ ] Hooks: script executável, `settings.json` válido (com os hooks anteriores preservados) e evento testado
- [ ] O usuário sabe como acionar o agente e como dar feedback

## Encerramento: diagrama Excalidraw (opcional)

Quando todos os níveis e o checklist final estiverem concluídos, **pergunte ao usuário** se quer gerar um diagrama Excalidraw para apresentar aos devs como o agente foi elaborado. Não gere sem a resposta. Pergunta sugerida:

> "Quer que eu gere um diagrama Excalidraw que explique como este agente foi construído, para apresentar ao time?"

Se o usuário aceitar, leia os arquivos reais do workspace (nunca invente conteúdo) e use a skill `excalidraw`, que fica em `.claude/skills/excalidraw/` (carregue-a com a ferramenta Skill, nome `excalidraw`, e siga o `SKILL.md` e as `references/` dela; se a pasta não existir, avise o usuário e gere o JSON seguindo o formato Excalidraw) para gerar o diagrama em `<workspace>/docs/<agente>-diagrama.excalidraw` (crie a pasta `docs/` se não existir, e acrescente-a à estrutura no `CLAUDE.md`), com estes blocos:

1. **Estrutura gerada:** árvore de pastas e arquivos criados (`CLAUDE.md`, `contexto/`, `.claude/agents|skills|memory|hooks|settings.json`, pasta de saídas), com uma legenda de uma linha por item.
2. **Entrada e saída:** o que o agente recebe (de onde vem, formato) e o que entrega (arquivo, formato, local), mais arquivos de status, se houver.
3. **Anatomia do agente:** frontmatter (`name`, `description`, `tools`, `model`, `skills`) e as 5 partes (cérebro, contexto, tarefa, regras, ferramentas), apontando em qual trecho do arquivo cada uma está.
4. **Anatomia da skill:** fluxo, checklist de qualidade, formato de saída, erros a evitar, e a relação agente x skill (quem faz x como se faz).
5. **Anatomia da memória:** arquivo de lições, quando é lido, quando é gravado, e o ciclo feedback → lição → próxima tarefa.
6. **Anatomia do hook:** evento, matcher, script e o código de saída que bloqueia; o que ele garante que o agente sozinho não garantiria.
7. **Para entender e apresentar:** fluxo completo de uma execução (acionamento → leitura de contexto e memória → processo → entrega → aprovação humana → feedback), limites e permissões do agente, como testar e como evoluir.

Regras do diagrama:
- Use os nomes e caminhos reais do workspace, e só inclua os blocos que existem (sem hook, omita o bloco 6).
- Texto curto e legível, em português; cores diferentes para agente, skill, memória, hook e arquivos de entrada/saída, com legenda.
- Gere o arquivo com todos os campos padrão de cada elemento (`angle`, `seed`, `version`, `isDeleted`, `groupIds`, `boundElements`, `lineHeight`, `files: {}` etc.), para abrir em qualquer leitor, e valide o JSON com `jq .`.
- Informe o caminho do arquivo gerado e como abri-lo: arrastar o arquivo para excalidraw.com, ou instalar uma extensão do Excalidraw no VS Code (sem ela, o VS Code mostra só o texto JSON). Avise que não foi possível conferir o visual.
- Se o usuário recusar, encerre com o resumo de como acionar o agente.
