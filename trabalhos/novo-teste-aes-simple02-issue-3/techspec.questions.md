# Perguntas do TechSpec: issue 3 (rodada 1)

Contexto da exploração:
- O repositório não versiona hoje nenhum código de aplicação (não há `package.json`, `src/` nem `test/`). O desenho parte do zero.
- Precedente no histórico: o app removido no commit 7c4356d usava CommonJS (`require`/`module.exports`), `src/` + `test/` e o runner nativo `node --test` com `node:assert`, sem framework externo de testes.
- Ambiente local: Node.js v24.18.0.
- O PRD já fixou o comportamento (RN-01 a RN-08). As perguntas abaixo tratam só de como construir.

Responda com o número e a letra (ex.: `Q1: A`). Se aceitar todas as recomendações, basta responder "todas as recomendações".

## Q1. Qual sistema de módulos a função usa?
**Recomendação: A, porque** é o padrão do Node sem configuração extra e repete o precedente do repositório (o app removido usava `require`/`module.exports`).
- A) CommonJS: `module.exports = { soma }` e `require('./src/soma')`.
- B) ES Modules: `export function soma(...)`, com `"type": "module"` no `package.json`.
- C) Outro: descreva.

## Q2. Qual ferramenta roda os testes automatizados?
**Recomendação: A, porque** já vem com o Node 24, não adiciona dependência e é o que o repositório usava antes (`"test": "node --test"`).
- A) Runner nativo `node:test` + `node:assert`, executado por `npm test` (`node --test`).
- B) Jest (dependência de desenvolvimento).
- C) Vitest (dependência de desenvolvimento).
- D) Outro: descreva.

## Q3. Qual o nome da função e onde ela fica?
**Recomendação: A, porque** o projeto, o PRD e as mensagens são em português, e `src/` + `test/` repete a estrutura que o repositório já usou.
- A) Função `soma` em `src/soma.js`; testes em `test/soma.test.js`.
- B) Função `sum` em `src/sum.js`; testes em `test/sum.test.js`.
- C) Outro: descreva (nome e caminho).

## Q4. Que tipo de erro a função lança quando recusa uma entrada?
**Recomendação: A, porque** `TypeError` é o erro nativo para "argumento do tipo errado", quem chama pode testar com `instanceof TypeError` sem importar nada novo, e a mensagem já distingue o caso (RN-06).
- A) `TypeError` em todos os casos (tipo, `NaN` e quantidade), com mensagens fixas que distinguem cada caso.
- B) `TypeError` para tipo/`NaN` e `RangeError` para quantidade errada.
- C) Classe própria `SomaError extends TypeError` com uma propriedade `code` (ex.: `ARG_COUNT`, `NOT_A_NUMBER`, `IS_NAN`).
- D) Outro: descreva.

## Q5. Em que idioma ficam as mensagens de erro?
**Recomendação: A, porque** o projeto e quem revisa trabalham em português, e os testes passam a comparar o texto exato.
- A) Português, com textos fixos: `soma: esperados exatamente 2 argumentos, recebidos <n>`, `soma: o <primeiro|segundo> argumento não é um número`, `soma: o <primeiro|segundo> argumento é NaN`.
- B) Inglês (ex.: `sum: expected exactly 2 arguments, got <n>`).
- C) Outro: descreva.
