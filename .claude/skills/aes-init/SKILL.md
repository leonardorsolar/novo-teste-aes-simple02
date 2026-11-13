---
name: aes-init
description: Escaneia o projeto inteiro e gera uma visão de projeto multi-audiência em .aes/project/ — um documento para Product Manager (_overview.md, o que o projeto faz e inventário de módulos), um para Tech Lead/Arquiteto (_architecture.md, camadas, stack, convenções, cross-cutting), um para Developer (_onboarding.md, comandos e um walkthrough de CRUD real), um consolidado de qualidade/testes/infraestrutura/CI/CD/auditoria de dependências (_quality.md, sempre gerado) e, condicionalmente, um guia de design/brand style guide (_design-system.md, só se houver sinal real de design system no código), um guia didático para dev júnior (_devmentor.md, com perguntas de verificação e exercícios), mais diagramas Mermaid (banco de dados, mapa de módulos), um board .excalidraw do projeto, um board .excalidraw condicional de design system e — quando a CLI do Archify (vendorizada junto da skill aes-projeto-arch) estiver disponível — um diagrama de arquitetura animado (architecture-animada.html). Use quando o usuário pedir "escaneia o projeto", "visão geral do projeto para o time", "gera overview do projeto para PM/tech lead/arquiteto/dev", "auditoria de qualidade/infra/dependências do projeto", "style guide/design system do projeto", "diagramas animados/mais sofisticados do projeto", "gera onboarding/explica o projeto para um júnior", ou disser explicitamente "aes-init". Não use para PRD/TechSpec/Tasks de uma feature específica — isso é aes-create-prd/aes-create-techspec/aes-create-tasks.
---

# AES Init — Visão de Projeto Multi-Audiência

Escaneia o repositório inteiro e produz, em `.aes/project/`, um retrato do
projeto lido por três audiências diferentes — Product Manager, Tech
Lead/Arquiteto de Software e Developer — mais os diagramas que sustentam
esse retrato (banco de dados, mapa de módulos) e um board Excalidraw
editável. Além dos relatórios profissionais diretos (multi-arquivo, no mesmo
espírito artefact-driven de `.aes/tasks/<slug>/`), produz **um** arquivo
didático, `_devmentor.md`, com perguntas de verificação, pensado para um dev
júnior aprender o projeto sozinho. Os demais arquivos não levam perguntas.

<HARD-GATE>
- **Nunca inventa módulo, tabela, endpoint ou convenção que não esteja confirmado no código real escaneado.** Fonte insuficiente para uma seção → a seção fica vazia com a lacuna registrada em `_scan-meta.md`, nunca preenchida com suposição — mesma disciplina em todos os arquivos desta skill.
- **O diagrama do banco reflete o schema real**, nunca modelagem "ideal" — toda tabela, campo e relação vem de um arquivo de schema/migration que existe de fato no projeto ( ver `references/scan-checklist.md` dessa skill, reaproveitado aqui por referência).
- **Todo elemento do `.excalidraw` precisa do conjunto completo de campos-base + extras por tipo.** Um elemento incompleto não gera erro nenhum — só falha silenciosamente no visualizador (forma some, texto não aparece, clique quebra) porque `frontend/public/excalidraw/index.js` chama `updateScene` direto, sem normalização. Isso já quebrou em produção duas vezes em `aes-create-excalidraw` pelo mesmo motivo — ver `references/excalidraw-project-board.md` para o formato completo e o script de validação.
- **`spec-project.excalidraw` nunca é sobrescrito automaticamente** depois de criado, mesmo que o código-fonte mude — é presumido editado pelo time a qualquer momento. Só é regenerado por pedido explícito do usuário, com confirmação antes de sobrescrever.
- **`.aes/` é sempre resolvido/criado na raiz do projeto** (mesmo nível de `package.json`/`CLAUDE.md`), nunca dentro de `backend/`, `frontend/` ou qualquer subpasta — mesmo comportamento que `aes-create-prd`/`aes-create-techspec`/`devmentor-dados` já assumem para `.aes/tasks/`. Antes de gravar qualquer coisa, resolve a raiz real do workspace (não o `cwd` de onde a skill foi chamada); se `.aes/` ainda não existir ali, esta skill é responsável por criá-lo — nunca em outro lugar.
- **Reaproveita, nunca redescobre.** Se `AGENTS.md`/`CLAUDE.md`/`.cursorrules`/`README.md` já documentam stack, comandos ou convenções, usa esses fatos como ponto de partida (citando a fonte) em vez de re-explorar do zero e arriscar contradizer o que já está documentado.
</HARD-GATE>

## Passo 0 — Reconhecimento e escaneamento técnico (reaproveitado)

1. Lê, se existirem: `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `README.md` — extrai stack, comandos e convenções já documentadas. Essas viram a base factual.
2. Segue o checklist técnico já validado em `references/scan-checklist.md` para: identificação de stack/ponto de entrada, schema completo do banco de dados, camadas e organização, comandos de desenvolvimento, convenções observáveis no código real. 
3. Além do checklist reaproveitado, faz um levantamento próprio de **inventário de módulos**: lista as pastas de domínio de nível superior em `backend/src/modules/<domain>/` (ou equivalente) e em `frontend/src/systems/<domain>/` (ou equivalente) — ver `references/module-map-rules.md` para como classificar cada uma.
4. Se `.aes/project/` já existir, verifica o hash de escaneamento salvo em cada arquivo (ver `references/output-format.md`) antes de decidir regravar — nunca escaneia e sobrescreve sem essa checagem.
5. **Containerização** — verifica `Dockerfile`, `docker-compose.yml`/`.yaml`, `.dockerignore` na raiz e em cada workspace confirmado no inventário. Ausência é fato a registrar em `_scan-meta.md`, nunca assumida como "provavelmente não usa Docker" nem preenchida por convenção de mercado.
6. **CI/CD** — verifica `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` ou equivalente. Se existir, lê o(s) arquivo(s) para extrair gatilhos (push/PR/schedule) e etapas principais (build/test/deploy) — só o que o arquivo declara de fato, nunca inferido do nome do job.
7. **Cloud/IaC** — verifica sinais de infraestrutura como código ou provedor cloud: `terraform/`, `*.tf`, `serverless.yml`, `vercel.json`, `railway.json`, `Procfile`, configs de AWS/GCP/Azure (`.aws/`, `app.yaml`, `azure-pipelines.yml`). Registra o que encontrar com o arquivo-fonte; ausência é só mais um fato, não uma lacuna a lamentar.
8. **Auditoria de dependências** — roda a auditoria de vulnerabilidades apropriada ao gerenciador de pacotes já identificado no item 2, em cada workspace com manifesto de dependências (`npm audit --json`, `pip-audit`, `cargo audit`, ou equivalente). Registra contagem por severidade (crítica/alta/média/baixa) por workspace. Comando indisponível ou sem equivalente para o gerenciador detectado → registra "auditoria de dependências não executada — [motivo]" em `_scan-meta.md`, nunca omite a seção em silêncio.
9. **Dependências não utilizadas** — tenta uma checagem, só se viável **sem alterar o projeto do usuário** (ex.: `npx depcheck` sem instalação global, sem tocar `package.json`/lockfile). Sem ferramenta equivalente viável para o gerenciador/linguagem do projeto → registra "não verificado — ferramenta de depcheck não disponível" em vez de pular sem nota.
10. **Variáveis de ambiente por workspace** — verifica `.env.example` (ou `.env.sample`/`.env.dist`) em **todos** os workspaces do inventário, não só no backend — cita explicitamente quais têm e quais não têm.
11. **Entrypoint por workspace** — confirma o ponto de entrada real de **cada** workspace (ex. `backend/src/index.ts` **e** `frontend/src/main.tsx`), estendendo a checagem única de entrypoint do checklist reaproveitado (pensada para um único app) para todo workspace do monorepo.
12. **Formatação** — além do linter já coberto pelo checklist reaproveitado, verifica formatter configurado (Prettier, `.editorconfig` ou equivalente) — arquivo de config citado, ou ausência registrada.
13. **Documentação de processo** — verifica `STYLE.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/` e pasta de ADRs (`docs/adr/`, `docs/decisions/`). Presença/ausência de cada um, citando o caminho quando existir.

## Estrutura de saída

```
.aes/
└── project/
    ├── _overview.md              # Product Manager
    ├── _architecture.md          # Tech Lead + Arquiteto de Software
    ├── _onboarding.md            # Developer
    ├── _design-system.md         # condicional — só se houver sinal real de design system
    ├── _devmentor.md             # Dev júnior — guia didático com perguntas de verificação
    ├── _quality.md               # sempre gerado — testes, lint, deps, CI/CD, infra
    ├── _scan-meta.md             # metadados do scan e lacunas
    └── diagrams/
        ├── geral.banco.md            # ER do banco inteiro (mermaid erDiagram)
        ├── geral.modulos.md          # mapa de módulos backend+frontend (mermaid flowchart)
        ├── geral.classe.md           # condicional — só se houver modelo de domínio além das tabelas
        ├── spec-project.excalidraw   # board único: mapa de módulos + visão geral do banco
        ├── design-system.excalidraw  # condicional — board separado, só se _design-system.md foi gerado
        ├── architecture-animada.html # opcional — ver "Diagrama animado (Archify)" abaixo
        └── _manifest.md              # índice de status de tudo acima
```

Regras de local, frontmatter, hash de regeneração e regravação: `references/output-format.md`.

Só `_devmentor.md` leva perguntas de verificação. Os demais têm audiência profissional (PM/tech lead/arquiteto/dev experiente) e formato de relatório direto.

## `_overview.md` — Product Manager

1. **O que é este projeto** — o problema que resolve, para quem, 1-2 parágrafos sem jargão técnico. Reaproveita `AGENTS.md`/`CLAUDE.md`/`README.md` como fonte-base quando existirem, citando a fonte.
2. **Inventário de módulos** — uma linha por módulo real do backend e por sistema real do frontend: nome, propósito em 1 frase, e um sinal de maturidade **objetivo e verificável** na estrutura de arquivos (ex.: "completo: routes+service+repository+schema+types" vs. "parcial: só repository, sem rotas expostas"). Nunca uma opinião subjetiva como "módulo robusto" — só fatos observáveis. Ver `references/module-map-rules.md` para a varredura exata.
3. **Estado atual notável / lacunas ao nível de produto** — ex.: "sem suíte de testes automatizada configurada", sempre citando a fonte (arquivo ou ausência dele) que sustenta a afirmação.

## `_architecture.md` — Tech Lead + Arquiteto

1. **Camadas/pastas principais e o porquê da separação** — não a árvore de arquivos inteira, só o que ajuda a entender a arquitetura.
2. **Estilo arquitetural nomeado explicitamente** (ex. "arquitetura em camadas (routes → service → repository)", "hexagonal", "monolito modular") — só nomeia se o padrão for consistente em 2-3 módulos do inventário; senão registra "não identificado um padrão único e consistente" em vez de forçar um rótulo.
3. **Stack e bibliotecas-chave por camada** — extraído do manifesto real (`package.json`/equivalente), nunca por suposição de convenção de mercado que o projeto não segue.
4. **Gerenciador de pacotes e entrypoint de cada workspace** — cita o gerenciador detectado (npm/yarn/pnpm/pip/poetry/etc.) e o ponto de entrada real de todo workspace do inventário (ex. `backend/src/index.ts` **e** `frontend/src/main.tsx`), não só do backend.
5. **Convenções observadas no código real**, com exemplo de arquivo concreto para cada uma — só vira "convenção" se consistente em 2-3 arquivos diferentes, não escolha isolada.
6. **Preocupações cross-cutting reais** encontradas no código (tratamento de erro centralizado, padrão de validação, padrão de migration) — só o que está de fato implementado, citando o arquivo.
7. **Ponteiros para os diagramas**: `diagrams/geral.banco.md`, `diagrams/geral.modulos.md`, `diagrams/geral.classe.md` (se gerado) e `diagrams/spec-project.excalidraw`.
8. **Ponteiros para `_quality.md`** (testes, lint, dependências, CI/CD, infra) **e para `_design-system.md`** se gerado — este arquivo não duplica esse conteúdo, só aponta para onde ele vive.
9. **Inconsistências entre documentação e código real**, se houver (ex.: `CLAUDE.md` descreve uma convenção que o código não segue mais) — sinaliza explicitamente, nunca tenta corrigir os outros arquivos.

## `_onboarding.md` — Developer

1. **Como rodar e testar localmente** — comandos essenciais, com uma frase de contexto em cada um (o que ele faz de fato).
2. **Walkthrough de CRUD ponta a ponta** com uma entidade real do projeto — rota → controller/handler → service → repository → banco, com o trecho de código essencial de cada camada e uma frase explicando o papel daquela camada ali. Escolhe a entidade com a cadeia mais completa e mais simples de seguir (nunca a mais complexa do sistema). Confirma que as quatro operações existem de fato antes de descrevê-las; se faltar uma, usa as que existem e nota a ausência.
3. **Exercícios práticos guiados** — 2-4 tarefas pequenas e não destrutivas para um dev novo executar sozinho no projeto real, em lista direta (o formato de quiz com resposta escondida fica só em `_devmentor.md`).

## `_devmentor.md` — Dev júnior (didático)

`AGENTS.md`/`CLAUDE.md`/`.cursorrules` são instruções para o **agente de IA**. `_devmentor.md` é para a **pessoa**: alguém entrando no projeto pela primeira vez, que precisa entender o "porquê" da estrutura, não só executar comandos. Reaproveita o levantamento do Passo 0 (não re-escaneia) e segue o formato didático de `references/didactic-template.md`.

**Regras deste arquivo (além do `HARD-GATE` geral):**
- Nunca despeja lista mecânica (todo script do `package.json`, toda pasta, toda dependência) sem explicar quando/por que usar. Cada fato vem com o raciocínio que o arquivo-fonte não dá.
- **Todo bloco termina com perguntas de verificação** — um bloco sem elas está incompleto.
- O padrão de CRUD usa uma entidade real do projeto; o diagrama do banco reflete o schema real.

**Sete blocos**, cada um em linguagem simples, com exemplo real do projeto, terminando em perguntas de verificação:
1. **O que é este projeto** — problema que resolve e para quem, 1-2 parágrafos sem jargão.
2. **Como o projeto é organizado** — camadas/pastas principais e o porquê da separação (não a árvore inteira).
3. **Como rodar e testar localmente** — comandos essenciais, com uma frase do que cada um faz de fato.
4. **Convenções do projeto** — nomenclatura e organização observadas no código real, citando arquivos de exemplo.
5. **Diagrama do banco de dados** — ver abaixo. Vem antes do CRUD de propósito.
6. **O padrão de CRUD da aplicação** — o bloco mais importante, ver abaixo.
7. **Exercícios práticos guiados** — 2-4 tarefas pequenas e não destrutivas, cada uma com dica progressiva e resposta esperada em `<details>`.

### Bloco 5 — Diagrama do Banco de Dados

1. Localiza o schema real do projeto (`schema.prisma`, arquivo de models do ORM, migrations, ou script SQL de criação de tabela) — nunca infere tabela a partir de nome de variável no código sem confirmar no schema.
2. Traduz o schema para um `erDiagram` Mermaid: uma entidade por tabela, campos com tipo, `PK`/`FK` marcados, relação (`||--o{`, `}o--o{`) com a cardinalidade real declarada no schema (chave estrangeira única = 1:N; tabela de junção = N:N) — nunca assume cardinalidade pelo nome do campo.
3. Antes do diagrama, explica em 1-2 frases, sem jargão, o que é chave primária e chave estrangeira — pressupõe que o júnior pode não saber, mesmo que pareça básico.
4. Depois do diagrama, para cada relação existente, uma frase concreta usando os nomes reais das tabelas (ex.: "cada `Task` pertence a um `Project`, mas um `Project` pode ter várias `Task` — é isso que a seta com `||--o{` mostra").
5. Se o schema tiver regra de exclusão em cascata (`onDelete: Cascade` ou equivalente) ou restrição de nulidade em uma FK, menciona isso explicitamente — é o tipo de detalhe que muda o comportamento de um Delete e conecta direto com o Bloco 6.

### Bloco 6 — Padrão de CRUD

1. Escolhe **uma entidade real** do projeto que tenha as quatro operações (ou o máximo delas) implementadas — nunca uma entidade hipotética. Prefere uma entidade que já apareceu no diagrama do Bloco 5, para o júnior conseguir ligar os dois blocos.
2. Percorre Create → Read → Update → Delete, uma de cada vez. Para cada operação, mostra a cadeia real de arquivos que a requisição atravessa (rota → controller/handler → service/use-case → repository/model → banco), com o trecho de código relevante de cada camada (curto, só a assinatura/corpo essencial) e uma frase explicando o papel daquela camada especificamente ali.
3. Ao final das quatro operações, resume o padrão em uma frase que o júnior consiga aplicar sozinho em outra entidade: "toda operação passa por [camadas, nessa ordem], e cada camada é responsável por [...]".
4. Fecha com o exercício-ponte: aponta uma rota do projeto que **não foi explicada** no walkthrough e pede para o júnior rastrear sozinho as mesmas camadas — resposta esperada em `<details>`, não revelada de cara.

Template completo (estrutura de código, formato de pergunta, formato de exercício) em `references/didactic-template.md`.

### Formato de pergunta de verificação (usado em todo bloco de `_devmentor.md`)

```markdown
### 🧪 Teste seu entendimento

<details>
<summary>1. [pergunta sobre o que acabou de ser explicado, nunca sobre detalhe decorável]</summary>

[resposta objetiva, 1-3 frases, referenciando o arquivo/trecho real quando fizer sentido]
</details>

<details>
<summary>2. [pergunta que exige aplicar o conceito, não só repetir]</summary>

[resposta]
</details>
```

3-5 perguntas por bloco. Nunca pergunta que se responde só copiando uma frase do texto acima — pelo menos uma pergunta por bloco deve exigir aplicar o conceito a uma situação nova (ex.: "se você precisasse adicionar um campo X, em quais dessas camadas você mexeria, e por quê?").

Se algo relevante não puder ser determinado (sem testes → Bloco 3 sem seção de testes; sem schema → Bloco 5 sem diagrama), diz isso explicitamente em vez de inventar.

## `_design-system.md` — Design / Brand Style Guide (condicional)

Só gerado se o Passo 0 confirmar **pelo menos um** sinal real de design system no código: arquivo de tokens CSS, `tailwind.config.*`, pasta de componentes de UI compartilhados (ex. `components/ui/`), ou Storybook configurado. Sem nenhum desses sinais, **o arquivo não é gerado** — registra em `_scan-meta.md`: "design system não encontrado no código — nenhum arquivo de tokens, config de Tailwind ou pasta de componentes UI compartilhados localizada". Esta skill só gera o arquivo em `.aes/project/`; não integra por conta própria com o frontend que consome essa pasta (mapeamento de aba → arquivo é responsabilidade de quem mantém esse frontend, fora do escopo desta skill).

1. **Origem dos tokens** — o(s) arquivo(s) real(is) de onde vêm (ex. `frontend/src/styles/index.css` + `tailwind.config.ts`), citado explicitamente.
2. **Paleta de cores encontrada** — nome do token conforme declarado (ex. `--primary`, `--accent`), com o valor resolvido ao lado; nunca um valor hardcoded inventado quando a fonte é uma CSS var. Logo depois da tabela, um bloco ` ```mermaid ``` ` (`flowchart`) redesenha a mesma tabela como swatches coloridos de verdade — a pipeline já renderiza blocos `mermaid` inline (`frontend/src/components/mermaid-diagram.tsx`, usado por `markdown-viewer.tsx`), então isso aparece direto no bloco "Design / Brand Style Guide", sem precisar abrir o `.excalidraw`. Regras do diagrama:
   - Um `subgraph` por agrupamento que a própria tabela já usa (ex. "Tema claro", "Tema escuro", e um por variante de accent, se houver) — nunca inventa agrupamento novo.
   - Um node por linha da tabela daquele grupo; `id` do node é o nome do token sanitizado para um identificador Mermaid válido, prefixado pelo grupo para não colidir entre temas (ex. `--primary` no tema claro → `light_primary`); o label do node é o nome do token exatamente como aparece na tabela (ex. `--primary`).
   - Um `style <id> fill:<hex>` por node. **A gramática de `style` do Mermaid não aceita a função `hsl(...)` — parênteses quebram o parser** (`mermaid.parse()` falha com `Expecting ... got 'PS'`, testado neste projeto). Por isso o valor `H S% L%` já documentado na tabela precisa ser convertido para hex (`#rrggbb`) antes de entrar no `style`; é uma conversão de formato mecânica e determinística (HSL→RGB→hex, arredondando cada canal para o inteiro mais próximo), não um valor recalculado/inventado — o número de origem continua sendo o mesmo já confirmado na tabela, só reescrito na única sintaxe que o `style` do Mermaid renderiza.
   - Quando a tabela já confirma o par `-foreground` daquele token (ex. `--primary` + `--primary-foreground`), soma `color:<hex do foreground>` ao mesmo `style` (mesmo hex convertido do valor já confirmado). Sem par dedicado, mas com um `--foreground` geral do mesmo grupo/tema já confirmado na tabela, usa esse valor em vez — é o mesmo token que o próprio tema usa como cor de texto padrão, reaproveitado do mesmo grupo, não uma cor nova inventada. Exceção: nos nodes `--foreground` e `--background` do próprio grupo, omite `color:` (usar o token como cor de si mesmo não faz sentido) e deixa o tema padrão do Mermaid decidir.
   - Quando a tabela do grupo já confirma um token `--border`, soma `stroke:<hex do border>`; senão omite `stroke:`.
   - Nunca inclui no diagrama um token que não esteja na tabela (mesmo HARD-GATE de não inventar); `--radius` fica de fora por não ser cor.
3. **Escala tipográfica encontrada** — fontes, pesos, tamanhos, só os que estão de fato declarados em algum arquivo de config/tema.
4. **Biblioteca de componentes usada** — detectada via `package.json` (ex. shadcn/ui + Radix, Material UI, Chakra); se nenhuma, registra ausência.
5. **Estados de componente observados no código** (hover/focus/disabled definidos em CSS ou variantes) — só com evidência real de que o estado está definido em algum lugar; nunca "provavelmente existe hover" por suposição. Fica como texto/tabela, nunca como swatch — o estado costuma vir de um modificador de opacidade sobre o token base (ex. `hover:bg-primary/90`), e recalcular a cor resultante seria um valor inventado, não confirmado.
6. **Icon set usado** — detectado via `package.json` + uso real em imports (ex. `lucide-react`), não só a presença da dependência sem uso confirmado. Logo depois, um segundo bloco ` ```mermaid ``` ` (`flowchart`, dois `subgraph`: "Componentes" e "Ícones") lista um node rotulado por componente de UI compartilhado (mesma lista do item 4) e por ícone confirmado em uso (mesma lista deste item) — mesmo conteúdo do bloco 3 de `design-system.excalidraw` (ver `references/excalidraw-project-board.md`), só que como preview inline em vez de board editável; sem cor de preenchimento — não desenha o ícone/componente de verdade, só o nome rotulado, mesma limitação do board Excalidraw.
7. **Link para Figma/Notion/PDF de design** — só se citado dentro do próprio repositório (README, comentário, arquivo de config); nunca inferido nem suposto que existe.
8. **Ponteiro para `diagrams/design-system.excalidraw`**, se gerado (ver "Diagramas" abaixo) — os dois blocos Mermaid acima (itens 2 e 6) são um preview inline gerado a partir da mesma tabela/lista já confirmada, não substituem o board: o Excalidraw continua sendo a versão editável pelo time (inclui também a escala tipográfica como amostra de texto real, que o Mermaid não reproduz).

## `_quality.md` — Qualidade, Testes & Infraestrutura (sempre gerado)

Diferente de `_design-system.md`, este arquivo é **sempre gerado**, mesmo que a maioria das seções fique só com "não encontrado" — a ausência de CI, testes ou infraestrutura documentada é em si informação relevante para quem lê esta aba. Consolida num único lugar o que hoje ficava espalhado entre `_architecture.md` e `_scan-meta.md`; reaproveita esse levantamento (Passo 0, itens 5-13) em vez de reprocessar do zero.

1. **Testes** — cobertura existente, framework(s) usado(s), comando para rodar; se nada configurado, diz isso explicitamente.
2. **Lint & formatação** — linter(s) e formatter(s) encontrados por workspace (ex. "ESLint presente, Prettier ausente"), com o arquivo de config citado ou a ausência registrada.
3. **Auditoria de dependências** — contagem de vulnerabilidades por severidade por workspace (Passo 0 item 8); dependências não utilizadas encontradas, ou "não verificado — ferramenta de depcheck não disponível sem alterar o projeto" (Passo 0 item 9) se não for viável.
4. **Containerização** — Docker/compose presente/ausente (Passo 0 item 5); se presente, resumo dos serviços declarados em `docker-compose.yml`.
5. **CI/CD** — pipeline presente/ausente (Passo 0 item 6); se presente, gatilhos e etapas principais extraídos do próprio arquivo.
6. **Cloud/IaC** — provedor e ferramenta de IaC, se detectados (Passo 0 item 7).
7. **Documentação de processo** — presença/ausência de ADRs, `CONTRIBUTING.md`, templates de PR/Issue, `STYLE.md`/`CODING_STANDARDS.md` (Passo 0 item 13).

Cada afirmação cita o arquivo-fonte ou declara ausência explicitamente — mesmo `HARD-GATE` de nunca inventar usado no resto da skill.

## `_scan-meta.md`

Timestamp ISO 8601 do scan, hash do commit git no momento (`git rev-parse HEAD`, ou nota explícita se a árvore estiver suja), e uma lista do que foi encontrado vs. o que não pôde ser determinado com confiança (ex.: "schema de banco não localizado — `_architecture.md` e `diagrams/geral.banco.md` ficam sem esse conteúdo, não inventados"). Registrado em arquivo próprio, além do resumo no fechamento da conversa.

## Diagramas

Fonte é o **código-fonte real do repositório inteiro**, não um `_techspec.md` — por isso os diagramas desta skill usam regras próprias, não as de `devmentor-dados/references/mermaid-conversion-rules.md` (essas partem de TechSpec/tasks já escritos, que não existem neste escopo).

1. **`diagrams/geral.banco.md`** — ER do banco inteiro, (schema real, `PK`/`FK` marcados, cardinalidade real da FK, nunca inferida por nome de campo, nota de cascata quando existir).
2. **`diagrams/geral.modulos.md`** — mapa de módulos backend+frontend. Regras completas em `references/module-map-rules.md`.
3. **`diagrams/geral.classe.md`** *(condicional)* — só se houver modelo de domínio tipado além das simples tabelas (ex.: DTOs/tipos ricos em `.types.ts`); senão pula e registra em `_scan-meta.md`. Regras em `references/module-map-rules.md`.
4. **`diagrams/spec-project.excalidraw`** — board com 2 diagramas (mapa de módulos + visão geral do banco), só se `geral.banco.md`/`geral.modulos.md` já tiverem conteúdo para basear. Formato completo, campos obrigatórios e script de validação em `references/excalidraw-project-board.md`.
5. **`diagrams/design-system.excalidraw`** *(condicional, só se `_design-system.md` foi gerado)* — board **separado** de `spec-project.excalidraw` (não um frame extra dentro dele, para não sobrecarregar um board que já tem regra própria de "nunca sobrescrito automaticamente"), com paleta de cores como swatches rotulados, escala tipográfica como amostras de texto, e a lista de componentes/ícones do inventário como blocos rotulados — mesmo espírito visual do board de módulos/banco, mesmo formato de campos e mesmo script de validação, ver seção própria em `references/excalidraw-project-board.md`. Nunca inventa cor/fonte/componente que `_design-system.md` não tenha confirmado.
6. **`diagrams/architecture-animada.html`** *(opcional, só se `.aes/app/archify/bin/archify.mjs` existir — é onde "Baixar Skills" vendoriza a CLI do Archify junto da skill `aes-projeto-arch`, ver `pipeline.skills.ts`)* — invoca a skill `../aes-projeto-arch` usando os componentes/relações já levantados para `_architecture.md` e `geral.modulos.md` como fonte factual (não re-escaneia o repositório do zero). Segue o procedimento normal dessa skill (autorar JSON em `.aes/project/arch/`, `validate`, depois `deliver`), mas com o output do `deliver` apontado direto para `diagrams/architecture-animada.html` em vez de `.aes/project/arch/` — ver "Output path" em `../aes-projeto-arch/SKILL.md`. Se `.aes/app/archify/bin/archify.mjs` não existir (skill ainda não baixada com o vendor do Archify), pula este passo e registra em `_scan-meta.md` que o diagrama animado não foi gerado por falta da CLI — nunca bloqueia o restante do scan por causa disso.
7. **`diagrams/_manifest.md`** — índice de status de tudo em `diagrams/`, regravado por completo a cada execução, incluindo a linha de `design-system.excalidraw` quando gerado. Formato em `references/output-format.md`.

## Validação antes de salvar

- Todo bloco ` ```mermaid ``` ` fechado corretamente; toda entidade/participante referenciado numa relação foi declarado antes no mesmo diagrama. Nos dois blocos Mermaid de `_design-system.md` (paleta de cores e componentes/ícones), todo `id` usado numa linha `style` corresponde a um node declarado no mesmo bloco, e todo valor de `fill`/`stroke`/`color` é hex (`#rrggbb`) — nunca a função `hsl(...)`, que a gramática de `style` do Mermaid não aceita (parênteses quebram o parser). Falhou → tenta gerar de novo uma vez; falhou de novo → para e mostra o erro, sem gravar arquivo quebrado.
- `spec-project.excalidraw`: roda o script de validação de `references/excalidraw-project-board.md` contra o JSON montado. Só escreve se passar sem `MISSING` nem binding quebrado.
- `design-system.excalidraw` (se gerado): mesmo script de validação, mesma regra — só escreve se passar sem `MISSING` nem binding quebrado.

## Ao final

A resposta ao usuário nunca é só "arquivos gerados" — resume o que foi encontrado (quantos módulos no inventário, quantas tabelas no banco, qual entidade foi escolhida para o walkthrough de CRUD, quais diagramas foram gerados vs. pulados por falta de fonte, incluindo se o diagrama animado saiu ou foi pulado por falta da CLI do Archify, e a entidade escolhida para o CRUD de `_devmentor.md`) antes de apontar os arquivos em `.aes/project/`. Adiciona explicitamente: se `_design-system.md` foi gerado ou pulado (e por quê), e um resumo de uma linha do que `_quality.md` encontrou (ex. "3 vulnerabilidades altas em backend, sem CI configurado, sem Docker"). Se algo relevante não pôde ser determinado com confiança, diz isso explicitamente (e já está registrado em `_scan-meta.md`) em vez de inventar.

## Reabertura

Se o usuário pedir para atualizar depois de mudança grande no projeto, recalcula o hash de escaneamento (`references/output-format.md`) e regenera só os arquivos cuja fonte mudou — nunca regrava `spec-project.excalidraw` nem `design-system.excalidraw` automaticamente, mesmo nesse caso.

Se `_devmentor.md` for regenerado e o júnior já tinha respondido as perguntas da versão anterior, avisa que elas podem ter mudado e vale revisar.
