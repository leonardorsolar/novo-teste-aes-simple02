# Formato de Saída, Local e Convenção de Regravação

## Resolução da raiz do projeto (fazer sempre, antes de qualquer gravação)

`.aes/` mora sempre na **raiz do projeto** — o mesmo nível de
`package.json`/`CLAUDE.md`, nunca dentro de `backend/`, `frontend/` ou de
uma subpasta. Antes de gravar qualquer arquivo desta skill:

1. Resolve a raiz real do workspace (o diretório que contém `package.json`
   de nível raiz e/ou `CLAUDE.md`/`.git`) — não assume que é o `cwd` de onde
   a skill foi chamada.
2. Se `.aes/` não existir ainda nessa raiz, cria `.aes/` ali (e `.aes/project/`
   dentro dele). Nunca cria `.aes/` em outro lugar, mesmo que pareça mais
   conveniente no momento.
3. Se `.aes/` já existir (por exemplo, porque `.aes/tasks/` já foi criado por
   `aes-create-prd` em alguma feature), reaproveita o mesmo diretório —
   `project/` é só mais uma pasta dentro dele, irmã de `tasks/`, `agents/`,
   `config.toml`.

## Estrutura de pastas

```
.aes/
├── config.toml                # se já existir, não é tocado por esta skill
├── tasks/                      # se já existir, não é tocado por esta skill
└── project/
    ├── _overview.md
    ├── _architecture.md
    ├── _onboarding.md
    ├── _devmentor.md              # guia didático para dev júnior
    ├── _design-system.md          # condicional — só se houver sinal real de design system
    ├── _quality.md                # sempre gerado
    ├── _scan-meta.md
    └── diagrams/
        ├── geral.banco.md
        ├── geral.modulos.md
        ├── geral.classe.md         # condicional
        ├── spec-project.excalidraw
        ├── design-system.excalidraw # condicional — só se _design-system.md foi gerado
        └── _manifest.md
```

- `diagrams/` é uma pasta plana, no mesmo padrão de `diagrams/` dentro de
  `.aes/tasks/<slug>/` — para quem for ler com um glob simples.
- `spec-project.excalidraw` e `_manifest.md` fogem da convenção
  `geral.<tipo>.md` de propósito — não são Mermaid, precisam ser
  distinguíveis sem abrir o arquivo.

## Frontmatter obrigatório

Todo arquivo `.md` gerado por esta skill (os documentos de `.aes/project/`
e os diagramas Mermaid em `diagrams/`) começa com:

```yaml
---
tipo: [overview | architecture | onboarding | design-system | quality | scan-meta | banco | modulos | classe]
gerado_a_partir_do_hash: [hash do conteúdo escaneado no momento da geração]
gerado_em: [timestamp ISO 8601]
---
```

`gerado_a_partir_do_hash` substitui o `gerado_com_techspec_versao` usado
pelos artefatos de `.aes/tasks/<slug>/diagrams/`, porque aqui não existe um
`_techspec.md` versionado como fonte — a fonte é o próprio código. O hash é
calculado sobre a concatenação estável (mesma ordem sempre) do conteúdo
relevante escaneado para aquele arquivo específico:

- `_overview.md`/`diagrams/geral.modulos.md`/`diagrams/geral.classe.md`: hash
  da listagem de pastas de módulos/sistemas + o conteúdo dos arquivos de
  barrel/manifesto de cada um (`index.ts`, `package.json` de cada módulo se
  houver, ou os arquivos-chave usados para classificar maturidade).
- `_architecture.md`: hash de `package.json` raiz + dos arquivos de
  configuração cross-cutting citados (ex. `shared/errors.ts`,
  `middleware/error-handler.ts`, equivalentes).
- `_onboarding.md`: hash dos arquivos da cadeia de CRUD escolhida (rota,
  service, repository, schema) + dos scripts de `package.json`.
- `_design-system.md`: hash do(s) arquivo(s) de tokens/tema (ex. CSS de
  variáveis, `tailwind.config.*`) + `package.json` (para a biblioteca de
  componentes e o icon set).
- `_quality.md`: hash de `package.json`/lockfile de cada workspace (para a
  auditoria de dependências) + dos arquivos de config de CI/CD, Docker e
  IaC encontrados no Passo 0 (itens 5-7) + dos arquivos de config de
  lint/formatter.
- `diagrams/geral.banco.md`: hash do(s) arquivo(s) de schema/migration.

Não precisa ser criptograficamente robusto — só estável o bastante para
detectar "a fonte relevante mudou desde a última geração". SHA-256 do
conteúdo concatenado é suficiente.

## Regra de regravação (para os `.md`, não para o `.excalidraw`)

Antes de escrever qualquer arquivo, lê o frontmatter do que já existe (se
existir):

| Situação | Ação |
|---|---|
| Arquivo não existe | Cria normalmente. |
| Existe, `gerado_a_partir_do_hash` bate com o hash recém-calculado | Não regrava. Avisa "já atualizado". |
| Existe, hash recém-calculado é diferente | Regenera e substitui automaticamente — sem perguntar. É projeção derivada do código, não uma decisão de produto/negócio. |
| Existe, hash bate mas o conteúdo salvo é diferente do que a skill geraria agora | Indício de edição manual. Para e pergunta: "Este arquivo parece ter sido editado manualmente depois de gerado. Quer que eu **substitua** pela versão gerada agora, ou **mantenha** a edição?" |

## Regra própria — `spec-project.excalidraw` e `design-system.excalidraw`

Nenhum dos dois entra na tabela acima — mesma regra para os dois arquivos:

| Situação | Ação |
|---|---|
| Arquivo não existe | Cria normalmente (`spec-project.excalidraw` se `geral.banco.md`/`geral.modulos.md` já tiverem conteúdo; `design-system.excalidraw` se `_design-system.md` foi gerado — ver SKILL.md). |
| Arquivo já existe, hash da(s) fonte(s) mudou (`geral.banco.md`/`geral.modulos.md` para um, `_design-system.md` para o outro) | **Não regrava.** Presumido editado pelo time a qualquer momento — sobrescrever perderia trabalho manual. |
| Usuário pede explicitamente para recriar ("gera de novo o excalidraw", "recria do zero") | Pergunta confirmação uma vez antes de sobrescrever. |

## Regra própria — `_manifest.md`

Sempre regravado por completo ao final de cada execução da skill, depois de
todos os outros artefatos de `diagrams/` processados — lista cada arquivo em
`diagrams/` com `status` (`atualizado` / `desatualizado` / `editado_manualmente`)
e `gerado_em`, incluindo `design-system.excalidraw` quando ele existir. Nunca
precisa de confirmação, porque só reflete o estado atual dos outros arquivos.

## Validação antes de salvar (arquivos Mermaid)

1. Todo bloco ` ```mermaid ... ``` ` fechado corretamente.
2. Toda entidade/participante referenciado numa relação foi declarado antes
   no mesmo diagrama.
3. Sintaxe do tipo de diagrama declarado bate com o conteúdo (`erDiagram` só
   contém sintaxe de ER, `flowchart` só sintaxe de flowchart, `classDiagram`
   só sintaxe de classe — sem misturar).

Falha em qualquer checagem → não grava, tenta gerar de novo uma vez. Falha
de novo → para e reporta o erro específico ao usuário, sem gravar arquivo
quebrado.

Validação específica de `spec-project.excalidraw` e de `design-system.excalidraw`
(mesmo formato, mesmo script): ver `references/excalidraw-project-board.md`.
