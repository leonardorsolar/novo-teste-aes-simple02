VERDICT: DONE

# PRD: Função de soma de dois números

## Resumo
Disponibilizar, em JavaScript, uma função chamada `sum` que recebe dois números e retorna a soma deles, exportada para ser importada por outros módulos e pelos testes. A soma segue a aritmética padrão do JavaScript, sem arredondamento. Testes automatizados acompanham a função. Origem: issue #3 (intake ACCEPT, risco baixo, rota feature, sem superfícies sensíveis).

## Visão Geral
A issue #3 pede "a soma de 2 números em javascript, de uma função que soma". O repositório hoje não tem código de aplicação (removido no commit 7c4356d), então não existe nenhuma função de soma. O valor é ter um bloco reutilizável e testado que outros módulos possam importar.

Usuários:
- Desenvolvedor consumidor: quem importa `sum` em outro módulo do projeto.
- Mantenedor: quem roda os testes para confirmar que a função continua correta.

## Objetivos
- Oferecer uma função `sum(a, b)` que retorna `a + b` para números.
- Garantir, por testes automatizados, o comportamento com positivos, negativos, zero e decimais.

## Funcionalidades Principais
- F1. Função `sum` exportada: recebe dois números e retorna a soma.
- F2. Comportamento numérico padrão do JavaScript para inteiros, negativos e decimais, sem arredondamento.
- F3. Testes automatizados cobrindo ao menos dois positivos, um negativo e zero, executáveis com `npm test`.

## Regras de Negócio
- RN-1. `sum(a, b)` retorna o resultado da adição padrão do JavaScript entre `a` e `b` (ex.: `sum(2, 3)` = `5`; `sum(-1, 1)` = `0`).
- RN-2. Decimais seguem a aritmética de ponto flutuante do JavaScript, sem arredondamento (ex.: `sum(0.1, 0.2)` = `0.30000000000000004`). Decisão do usuário (ADR-002).
- RN-3. A função não valida o tipo das entradas; o resultado para entradas que não sejam número não é especificado.
- RN-4. O nome público da função é `sum` (ADR-001).

## Experiência do Usuário
Não há interface. A experiência do desenvolvedor consumidor é: importar `sum`, chamar com dois números, receber a soma. A do mantenedor é: rodar `npm test` e ver os testes passarem.

## Restrições Técnicas de Alto Nível
- Linguagem JavaScript, executável em Node.
- Testes com o runner nativo do Node (`node:test`), rodando com `npm test` (definido no intake).
- O repositório não tem `package.json` hoje; a disponibilidade de `npm test` é parte do que a entrega precisa garantir. Como estruturar fica para a especificação técnica.

## Não-Objetivos (Fora de Escopo)
Todos vêm do `## Scope` do intake:
- Validação de tipos ou erros para entradas que não sejam números.
- Somar mais de dois números.
- Interface de linha de comando, rota HTTP ou interface visual.
- Recriar o servidor Express removido no commit 7c4356d.
- Corrigir o `README.md`, que ainda descreve `src/`, `test/` e Express.
- Arredondamento ou correção de ruído de ponto flutuante (decisão do usuário, Q1).

## User Stories

| ID | Persona | Resumo | Funcionalidade |
|---|---|---|---|
| US-001 | Desenvolvedor consumidor | Somar dois números com `sum` | F1, F2 |
| US-002 | Mantenedor | Rodar testes automatizados da soma | F3 |

### US-001: Somar dois números
Como desenvolvedor consumidor, quero importar `sum` e chamá-la com dois números, para obter a soma sem reimplementá-la.

Critérios de aceite:
- US-001.AC-1: `sum` está exportada e pode ser importada por outro módulo e pelos testes.
- US-001.AC-2: `sum(2, 3)` retorna `5`.
- US-001.AC-3: `sum(-1, 1)` retorna `0` e `sum(-2, -3)` retorna `-5`.
- US-001.AC-4: `sum(0, 0)` retorna `0` e `sum(7, 0)` retorna `7`.
- US-001.AC-5: `sum(0.5, 0.25)` retorna `0.75`.

Casos de borda:
- US-001.EC-1: `sum(0.1, 0.2)` retorna `0.30000000000000004`, sem arredondamento.
- US-001.EC-2: valores muito grandes que excedam o limite do JavaScript resultam em `Infinity`, conforme a aritmética padrão.
- US-001.EC-3: entradas que não são números (texto, `undefined`, `null`): comportamento não especificado e fora de escopo; nenhuma validação é exigida.
- US-001.EC-4: ordem dos argumentos não altera o resultado (`sum(a, b)` = `sum(b, a)`).
- US-001.EC-5: `sum(-0, 0)` retorna `0`, conforme a aritmética padrão.

### US-002: Rodar os testes da soma
Como mantenedor, quero rodar `npm test` e ver os testes da `sum`, para confirmar que ela continua correta.

Critérios de aceite:
- US-002.AC-1: `npm test` executa os testes com `node:test` e termina com sucesso quando a função está correta.
- US-002.AC-2: Os testes cobrem ao menos dois positivos, um número negativo e zero.
- US-002.AC-3: Se `sum` retornar valor errado, `npm test` falha.

Casos de borda:
- US-002.EC-1: Um teste de decimais, se existir, espera o resultado padrão do JavaScript (RN-2), não um valor arredondado.
- US-002.EC-2: Os testes não dependem de rede, banco ou outros serviços.

## Registro de Decisões de Produto

### ADR-001: Nome da função é `sum`
- Status: Aceita. Data: 2026-11-12.
- Decisão: a função se chama `sum`.
- Alternativas: `soma` (usada como exemplo no intake; descartada pelo usuário); outro nome.
- Consequências: o contrato público usa o nome em inglês; os exemplos do intake com `soma` passam a valer como `sum`.

### ADR-002: Decimais seguem a aritmética padrão do JavaScript
- Status: Aceita. Data: 2026-11-12.
- Decisão: sem arredondamento; `0.1 + 0.2` resulta em `0.30000000000000004`.
- Alternativas: arredondar para eliminar o ruído de ponto flutuante (mais intuitivo, mas adiciona regra e perde fidelidade).
- Consequências: comportamento previsível para quem conhece JavaScript; consumidores que precisem de precisão decimal devem tratá-la por conta própria.

## Contexto da Pesquisa
Trilha A (código):
- Não existe código de aplicação na `main`: só `.aes`, `.claude`, `trabalhos` e `README.md`.
- O commit 7c4356d removeu `package.json`, `src/` e `test/`.
- Não há função de soma nem issue/PR duplicado (conforme intake).
- O `README.md` está desatualizado (descreve Express); fora de escopo.

Trilha B (mercado): dispensada (feature Trivial: função pura sem regra de negócio nova).

## Perguntas e Respostas
- Q1. Como tratar decimais? Resposta: A, aritmética padrão do JavaScript, sem arredondamento. Decidiu RN-2, ADR-002 e US-001.EC-1.
- Q2. Qual nome da função? Resposta: B, `sum`. Decidiu RN-4 e ADR-001.

## Premissas
- (suposição) Os dois argumentos são tipo número; nenhum comportamento é garantido para outras entradas (coerente com o intake).
- (suposição) "Exportada" significa disponível para importação por outros módulos do projeto; o formato de módulo fica para a especificação técnica.
- Sem ferramenta de pesquisa de mercado: trilha B dispensada pela classificação Trivial.

## Glossário
- Aritmética padrão do JavaScript: adição de números em ponto flutuante de 64 bits, como o operador `+` faz entre números.
- `node:test`: runner de testes nativo do Node.
- Desenvolvedor consumidor: quem importa e usa `sum` em outro módulo.
- Mantenedor: quem roda e mantém os testes.

## Perguntas em Aberto
Nenhuma.
