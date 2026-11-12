# Checklist de Escaneamento

O que investigar antes de escrever qualquer bloco — mesma disciplina do agente `Explore`/`/init`: ler antes de descrever, nunca supor.

## 1. Arquivos de orientação já existentes (ler primeiro, sempre)

- `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md` — extrai stack, comandos, convenções já documentadas para reaproveitar.
- `README.md` — propósito do projeto, instruções de setup que já existem.

Se esses arquivos contradizem o que o código realmente faz (ex.: `AGENTS.md` diz "usa Yarn" mas só existe `package-lock.json`), o `_devmentor.md` segue o código real e sinaliza a divergência num comentário curto, sem tentar corrigir os outros arquivos.

## 2. Identificação de stack e ponto de entrada

- Arquivo de manifesto (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, etc.) — linguagem, framework principal, versão.
- Ponto de entrada real (`main.ts`/`main.py`/`main.go`/`app.ts`/`index.ts` — o que o comando de start efetivamente executa).
- Arquivo de configuração de banco/ORM (`schema.prisma`, `models.py`, migrations) se existir.

## 3. Schema completo do banco de dados

- Localiza o arquivo de schema/model do ORM (`schema.prisma`, `models.py`, arquivos de `models/` do Django/SQLAlchemy, entidades do TypeORM) ou, na ausência de ORM, as migrations/scripts SQL de criação de tabela.
- Lê **todas** as tabelas/entidades do schema, não só a que vai aparecer no walkthrough de CRUD — o diagrama do Bloco 5 mostra o banco inteiro.
- Para cada tabela: nome dos campos, tipo, se é chave primária/estrangeira, se é opcional (nullable), e valor default se houver.
- Para cada chave estrangeira: a cardinalidade real (declarada no schema, nunca inferida pelo nome do campo) e se há regra de cascata (`onDelete: Cascade`/`SET NULL`/restrição de exclusão) — isso alimenta a nota do Bloco 5 sobre cascata e conecta com o comportamento de Delete no Bloco 6.

## 4. Camadas e organização

- Estrutura de pastas de nível superior dentro de `src/` (ou equivalente) — mas só as que representam uma camada ou responsabilidade real (rotas, controllers, services, repositories, models) — não lista pasta de configuração/build irrelevante para entendimento de arquitetura.
- Um arquivo de rota/controller real para confirmar o padrão de nomenclatura e a cadeia de chamada até o banco.

## 5. Fluxo CRUD real (para o Bloco 6)

- Escolhe a entidade que tem a cadeia mais completa e mais simples de seguir (evita a entidade mais complexa do sistema — o objetivo é didática, não exaustividade). Prefere uma entidade já mapeada no schema (item 3).
- Localiza e lê, para essa entidade: arquivo de rota, controller/handler, service/use-case, repository/model, e o schema/model de dados.
- Confirma que as quatro operações (Create/Read/Update/Delete) realmente existem para essa entidade — se faltar uma, usa as que existem e nota a ausência (não inventa a que falta).

## 6. Comandos de desenvolvimento

- Scripts de `package.json`/Makefile/equivalente: só os que um dev usa no dia a dia (start, test, lint, migration) — não todo script auxiliar de CI/deploy.
- Roda (ou confirma pela leitura) se há suíte de teste automatizado configurada, e qual framework.

## 7. Convenções observáveis (não inventadas)

- Nomenclatura de arquivo e de função/classe usada de fato em pelo menos 2-3 arquivos diferentes — só vira "convenção do projeto" se for consistente entre eles, não uma escolha isolada de um único arquivo.
- Ferramenta de lint/formatação configurada (arquivo de config presente), se houver.

## O que explicitamente NÃO escanear/incluir

- Dependências transitivas ou de build tooling que não afetam como o dev escreve código de feature.
- Histórico de commits ou autoria — fora de escopo para onboarding técnico.
- Qualquer credencial, variável de ambiente com valor real, ou segredo — cita só o *nome* da variável, nunca o valor, mesmo que esteja visível num `.env` de exemplo.
