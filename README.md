# novo-teste-aes-simple02

Projeto de teste da plataforma AES (Orquestrador), criado para validar o fluxo de ciclo SDD e as ferramentas de fábrica do repositório.

## Estrutura

- `.claude/agents/` — definições de agentes do projeto (ex.: `intake`, responsável por triar issues do GitHub).
- `.aes/` — estado local da plataforma (atividade e tarefas). Não é versionado.
- `src/` — código da aplicação: `app.js` cria o app Express e `server.js` inicia o servidor.
- `test/` — testes automatizados da aplicação.

## Tecnologias

- Node.js
- Express
- Testes com o runner nativo `node:test` e `supertest`

## Pré-requisitos

- Git
- Node.js (versão 18 ou superior)
- GitHub CLI (`gh`), opcional, para criar e publicar o repositório remoto

## Instalação

```bash
npm install
```

## Execução

```bash
npm start
```

O servidor escuta na porta 3000 por padrão. Para usar outra porta, defina a variável `PORT`:

```bash
PORT=8080 npm start
```

Exemplo de requisição:

```bash
curl http://localhost:3000/
# Hello World
```

## Testes

```bash
npm test
```

## Licença

Não definida.
