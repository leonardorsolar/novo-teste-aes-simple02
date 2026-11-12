# Template Didático — `_devmentor.md`

## Esqueleto do documento

```markdown
# Guia de Onboarding

> Este arquivo é para VOCÊ entender o projeto — não é lido por agentes de IA.
> Para instruções que o agente de IA segue, veja `AGENTS.md`/`CLAUDE.md`/`.cursorrules`.
> Gerado a partir do código real do projeto em [data]. Se algo aqui não bater com o
> que você está vendo, o código manda — e vale atualizar este arquivo.

## 1. O que é este projeto

[1-2 parágrafos, sem jargão: qual problema resolve, para quem]

### 🧪 Teste seu entendimento
<details><summary>1. [pergunta]</summary>[resposta]</details>
<details><summary>2. [pergunta]</summary>[resposta]</details>

## 2. Como o projeto é organizado

[camadas/pastas principais e o porquê da separação — não a árvore inteira]

### 🧪 Teste seu entendimento
[3-5 perguntas]

## 3. Como rodar e testar localmente

[comandos essenciais, cada um com 1 frase de contexto]

### 🧪 Teste seu entendimento
[3-5 perguntas]

## 4. Convenções do projeto

[padrões observados no código real, com arquivo de exemplo citado]

### 🧪 Teste seu entendimento
[3-5 perguntas]

## 5. Diagrama do banco de dados

[explicação rápida de PK/FK + erDiagram Mermaid do schema real + uma frase por relação — ver exemplo abaixo]

### 🧪 Teste seu entendimento
[3-5 perguntas]

## 6. O padrão de CRUD da aplicação

[walkthrough Create → Read → Update → Delete de uma entidade real — ver seção própria abaixo]

### 🧪 Teste seu entendimento
[3-5 perguntas, incluindo o exercício-ponte de rastrear uma rota não explicada]

## 7. Exercícios práticos guiados

[2-4 tarefas pequenas e seguras, cada uma com dica progressiva + resposta em <details>]
```

## Exemplo completo do Bloco 5 — Diagrama do Banco de Dados

```markdown
## 5. Diagrama do banco de dados

Antes de ver as tabelas, dois termos que vão aparecer o tempo todo:

- **Chave primária (PK)**: o campo que identifica uma linha de forma única naquela
  tabela — normalmente `id`.
- **Chave estrangeira (FK)**: um campo que guarda o `id` de uma linha *de outra
  tabela*, criando a ligação entre elas.

Este é o schema real do projeto (`prisma/schema.prisma`):

​```mermaid
erDiagram
    TASK ||--o{ COMMENT : recebe
    TASK {
        int id PK
        string title
        string status
        string developer
        datetime createdAt
    }
    COMMENT {
        int id PK
        string text
        int task_id FK
        datetime createdAt
    }
​```

- Cada `Task` pode ter várias `Comment`, mas cada `Comment` pertence a exatamente
  uma `Task` — é isso que a notação `||--o{` mostra (um lado "exatamente um", outro
  lado "zero ou muitos").
- `Comment.task_id` é a chave estrangeira que faz essa ligação — no banco, é
  literalmente o `id` de uma linha da tabela `Task` guardado dentro de `Comment`.
- O schema declara `onDelete: Cascade` em `task_id` — na prática, isso significa que
  deletar uma `Task` deleta automaticamente todos os `Comment` ligados a ela, sem
  precisar de código extra fazendo isso. Vale lembrar disso quando você chegar no
  Delete do Bloco 6.

### 🧪 Teste seu entendimento

<details>
<summary>1. O que diferencia uma chave primária de uma chave estrangeira?</summary>

A chave primária identifica a própria linha dentro da sua tabela. A chave
estrangeira aponta para a chave primária de uma linha *em outra tabela* — é o que
cria a relação entre as duas.
</details>

<details>
<summary>2. Se você deletar uma `Task` que tem 3 `Comment` associados, o que
acontece com os comentários — e onde essa regra está definida?</summary>

Os 3 comentários são deletados junto, automaticamente — não é o código da
aplicação que faz isso, é a regra `onDelete: Cascade` definida no próprio schema
do banco.
</details>

<details>
<summary>3. Se o projeto precisasse que uma `Task` pudesse ter vários
responsáveis (em vez de um `developer` só), o que mudaria no diagrama?</summary>

`developer` deixaria de ser um campo de texto solto em `Task` e viraria uma tabela
própria (ex.: `Developer`), com uma tabela de ligação N:N entre `Task` e
`Developer` — porque agora uma Task pode ter vários devs, e um dev pode estar em
várias Tasks.
</details>
```

## Exemplo completo do Bloco 6 — Padrão de CRUD

Baseado numa API de gerenciamento de tarefas (Express + Prisma), para servir de modelo de nível de detalhe e tom:

```markdown
## 6. O padrão de CRUD da aplicação

Toda operação neste projeto passa pela mesma cadeia de 4 camadas, sempre na mesma ordem:

`Rota → Controller → Service → Repository → Banco (Prisma)`

Cada camada tem uma responsabilidade só, e não pula a ordem — o Controller nunca
chama o Repository direto, por exemplo. Vamos seguir essa cadeia usando a entidade
`Task`, olhando as quatro operações uma por vez.

### Create — criar uma tarefa

**Rota** (`src/routes/taskRoutes.ts`): recebe `POST /tasks` e só direciona pro Controller — não valida nada aqui.

**Controller** (`src/controllers/taskController.ts`): pega o corpo da requisição (`req.body`) e chama o Service. Se der erro, decide o status HTTP da resposta.

**Service** (`src/services/taskService.ts`): é aqui que fica a regra de negócio — por exemplo, validar que `title` não é vazio. O Controller nunca valida regra de negócio sozinho.

**Repository** (`src/repositories/taskRepository.ts`): só fala com o Prisma. Não tem `if` de regra de negócio aqui — só monta a query.

```typescript
// repository — só acesso a dado, sem decisão de negócio
async create(data: CreateTaskInput): Promise<Task> {
  return this.prisma.task.create({ data });
}
```

### Read — listar e buscar uma tarefa

Mesma cadeia, mas o Service aqui normalmente não tem muita regra — o interessante de
Read é que o Repository pode ter dois métodos (`findAll`, `findById`) em vez de um,
porque são duas formas diferentes de "ler".

### Update — atualizar uma tarefa

Repare que o Service de Update costuma ter uma etapa a mais que o Create: primeiro
confirma que a tarefa existe (senão o Repository do Prisma lança um erro que precisa
virar 404, não 500), só depois manda atualizar.

### Delete — remover uma tarefa

Mesmo padrão do Update: o Service confirma existência antes de chamar o Repository,
e traduz o erro "não encontrado" do Prisma (`P2025`) para um erro de aplicação
(`NotFoundError`) que o Controller sabe transformar em `404`.

### O padrão, resumido numa frase

Toda operação vai **Rota (recebe) → Controller (traduz erro em status HTTP) →
Service (decide a regra de negócio) → Repository (só fala com o banco)** — e nenhuma
camada pula a próxima.

### 🧪 Teste seu entendimento

<details>
<summary>1. Por que o Repository não tem nenhum `if` de validação de negócio?</summary>

Porque validação de negócio é responsabilidade do Service — o Repository só sabe
conversar com o banco. Se o Repository validasse, a regra ficaria espalhada em duas
camadas e mais difícil de mudar depois.
</details>

<details>
<summary>2. Se você precisasse impedir que uma tarefa fosse deletada quando ela tem
subtarefas pendentes, em qual camada você adicionaria essa checagem — e por quê?</summary>

No Service — é regra de negócio, não é sobre como acessar o banco (isso desqualifica
o Repository) nem sobre formato de resposta HTTP (isso desqualifica o Controller).
</details>

<details>
<summary>3. Exercício-ponte: dá uma olhada na rota `PATCH /tasks/:id/status` (que não
foi explicada acima). Sem ler o código ainda, o que você espera encontrar em cada
camada, seguindo o mesmo padrão?</summary>

Rota mapeando `PATCH /tasks/:id/status` pro Controller; Controller pegando
`req.params.id` e `req.body.status`; Service validando se o novo status é um valor
permitido (regra de negócio) e se a tarefa existe; Repository só rodando o `update`
no Prisma. Agora abre o arquivo de verdade e confere se bateu.
</details>
```

## Exemplo do Bloco 7 — Exercícios Práticos

```markdown
## 7. Exercícios práticos guiados

Tarefas pequenas e seguras para você fixar o padrão da Seção 5 — nenhuma delas exige
mexer em código de produção, só rodar localmente.

### Exercício 1 — Rastrear uma operação do início ao fim

Escolha a rota `GET /tasks/:id` e escreva, num arquivo à parte, o caminho completo
que uma requisição percorre até a resposta voltar — cite o nome do arquivo e do
método em cada camada.

<details><summary>Resposta esperada</summary>

`taskRoutes.ts` (rota) → `taskController.ts:getById` → `taskService.ts:findById`
→ `taskRepository.ts:findById` → `prisma.task.findUnique`.
</details>

### Exercício 2 — Adicionar um campo novo (sem persistir)

Sem alterar o schema do Prisma, adicione um campo calculado `isOverdue: boolean` na
resposta de `GET /tasks/:id`, calculado a partir de `createdAt`. Em qual camada essa
lógica deveria entrar?

<details><summary>Dica</summary>
Não é acesso a dado puro (não é Repository) nem formatação de resposta HTTP crua
(não é Controller) — é derivação de regra sobre o dado.
</details>

<details><summary>Resposta esperada</summary>
No Service, geralmente na função que já busca a tarefa antes de devolver ao
Controller — mantém a mesma separação de responsabilidade do resto do padrão.
</details>
```

## Regras de formatação a seguir sempre

- Todo trecho de código citado existe de fato no projeto — nunca pseudocódigo apresentado como se fosse real.
- Nomes de arquivo sempre com caminho relativo real (`src/services/taskService.ts`), nunca `arquivo.ts` genérico.
- Perguntas de verificação usam `<details><summary>` para a resposta ficar escondida por padrão — isso é o que torna o teste de entendimento real (o júnior tenta responder antes de abrir).
- Tom didático: frases curtas, sem assumir que o júnior já conhece o termo técnico usado — na primeira vez que um termo aparece (ex.: "regra de negócio", "camada de acesso a dado"), explica em poucas palavras o que significa.
