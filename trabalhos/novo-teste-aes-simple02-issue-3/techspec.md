VERDICT: DONE

# TechSpec: Função de soma de dois números (issue #3)

> **Divergência com o PRD (leia primeiro).** Nas respostas do techspec (`techspec.answers.md`), o usuário escolheu **script global sem export** (Q1) e **nenhum teste automatizado** (Q2). Essas escolhas contrariam três pontos do `prd.md`: F3 ("a função é exportada" e "vem com testes automatizados"), US-004 AC-1 ("outro módulo importa a função"), US-004 AC-3 ("a suíte de testes automatizados [...] todos os testes passam") e a Restrição Técnica "testes automatizados são obrigatórios". Este techspec segue a decisão do usuário (ADR-006, ADR-007) e mostra na seção [Divergências com o PRD](#divergências-com-o-prd) como cada ponto fica. Para manter PRD e techspec coerentes, o `prd.md` deve ser revisado pelo agente `prd`. Este techspec não altera o PRD.

## Resumo Executivo

A entrega é um único arquivo, `src/soma.js`. Ele declara no escopo global a função `soma(a, b)`, sem `module.exports`, sem `export` e sem `package.json`. A função verifica primeiro a quantidade de argumentos (`arguments.length === 2`). Depois verifica cada argumento, na ordem: o tipo (`typeof === "number"`) e em seguida o `NaN` (`Number.isNaN`). Se tudo passar, devolve `a + b` nativo. Toda recusa lança `TypeError` com uma mensagem fixa em português que aponta a causa e o argumento (ADR-008).

Quem usa a função carrega `src/soma.js` no mesmo contexto global do seu código: um `<script>` clássico no navegador, ou `vm.runInThisContext` ou `.load` no Node. Um `require('./src/soma.js')` não expõe a função, porque o CommonJS isola as declarações do arquivo. Não há suíte automatizada. O contrato de testes deste documento (UT/IT/E2E) é um catálogo de casos com valores e saídas exatas. O revisor roda esses casos à mão pelo roteiro em [Abordagem de Testes](#abordagem-de-testes). O trade-off principal é trocar a garantia de regressão automática e a importação explícita por um artefato mínimo, sem dependências nem configuração.

## Arquitetura do Sistema

### Visão Geral dos Componentes

| Componente | Arquivo | Responsabilidade | Limites |
|---|---|---|---|
| `soma` (função global) | `src/soma.js` (novo) | Validar quantidade, tipo e `NaN` (F2) e devolver a soma nativa (F1). Fica disponível para outros scripts por declaração global (F3, adaptada pela ADR-006). | Não lê nem grava estado, não faz I/O e não depende de nada. É o único componente. |
| Script consumidor | fora do repositório (qualquer script carregado depois) | Chamar `soma` no mesmo contexto global | Não faz parte da entrega. Aparece só nos casos IT/E2E. |

Fluxo de dados: chamador → `soma(a, b)` → [RN-01 quantidade] → [RN-02 tipo do 1º, RN-03 `NaN` do 1º] → [RN-02 tipo do 2º, RN-03 `NaN` do 2º] → `return a + b`. Qualquer falha interrompe o fluxo com `throw new TypeError(mensagem)`.

Não há sistemas externos.

### Mapeamento PRD → componente

| Item do PRD | Componente / mecanismo |
|---|---|
| Objetivo 1, F1, US-001, RN-04, RN-05 | `soma`: `return a + b` sem conversão nem arredondamento |
| Objetivo 2, F2, US-002, RN-02, RN-03, RN-06 | `soma`: checagem `typeof` + `Number.isNaN` por argumento, com mensagens fixas |
| Objetivo 3 | `soma`: só devolve `a + b` depois que os dois argumentos passaram por `typeof === "number"` e não são `NaN` |
| US-003, RN-01, RN-07 | `soma`: `arguments.length !== 2`, verificado antes de qualquer checagem de tipo |
| RN-08, US-001.EC-5, US-002.EC-8 | `soma`: função pura, sem variáveis fora do corpo e sem escrita nos argumentos |
| F3, US-004 | Declaração global em `src/soma.js` (ADR-006). Os testes viram um catálogo manual (ADR-007). Ver Divergências. |

## Design de Implementação

### Interfaces Principais

Interface única, em JavaScript (linguagem pedida na issue):

```js
/**
 * Soma exatamente dois números pela aritmética nativa do JavaScript.
 * Aceita inteiros, negativos, zero, decimais e ±Infinity; recusa o resto.
 * @param {number} a primeiro número (primitivo, diferente de NaN)
 * @param {number} b segundo número (primitivo, diferente de NaN)
 * @returns {number} a + b nativo (pode ser Infinity ou, só em Infinity + -Infinity, NaN)
 * @throws {TypeError} quantidade de argumentos diferente de 2, argumento não numérico ou NaN
 */
function soma(a, b) { /* ver Convenções */ }
```

Convenções (contrato que o implementador segue à risca):

1. `"use strict";` no início do corpo da função, não no topo do arquivo. Assim o modo estrito não vaza para outros scripts concatenados.
2. Ordem das verificações (RN-07, RN-06):
   1. `arguments.length !== 2` → `TypeError("soma: esperados exatamente 2 argumentos, recebidos " + arguments.length)`.
   2. Para cada argumento, na ordem 1º e depois 2º, com `ordinal` igual a `"primeiro"` ou `"segundo"`:
      - `typeof x !== "number"` → `TypeError("soma: o " + ordinal + " argumento não é um número")`. Isso cobre texto, `null`, `undefined`, booleano, objeto, array, função, `BigInt` e `new Number(...)`.
      - `Number.isNaN(x)` → `TypeError("soma: o " + ordinal + " argumento é NaN")`.
   3. `return a + b;`
3. Mensagens exatas (Q5 = A), com o texto entre aspas copiado literalmente:

| Caso | Mensagem |
|---|---|
| Quantidade | `soma: esperados exatamente 2 argumentos, recebidos <n>` |
| Tipo | `soma: o primeiro argumento não é um número` / `soma: o segundo argumento não é um número` |
| `NaN` | `soma: o primeiro argumento é NaN` / `soma: o segundo argumento é NaN` |

4. A função não converte valores (`Number(x)`, `+x`, `parseFloat` são proibidos), não lê propriedades dos argumentos e não usa variáveis fora do próprio corpo.
5. O arquivo contém só a declaração `function soma(a, b) {...}` com seu JSDoc. Não há `module.exports`, `export`, `globalThis.soma = ...` nem IIFE (ADR-006).

### Modelos de Dados

Não se aplica: a função não tem entidades, persistência nem estado.

### Endpoints de API

Não se aplica: não há HTTP, CLI nem UI (Não-Objetivos do PRD).

## Pontos de Integração

Não se aplica: não há serviço externo. O único limite é o contexto global JavaScript em que `src/soma.js` é carregado:
- **Navegador:** `<script src="src/soma.js"></script>` clássico, sem `type="module"`. A função fica em `window.soma` para os scripts carregados depois.
- **Node.js (v24 local):** `vm.runInThisContext(fs.readFileSync("src/soma.js", "utf8"))` ou, no REPL, `.load src/soma.js`. A função fica em `globalThis.soma`. `require` não serve (ver Riscos).

## Análise de Impacto

| Componente | Tipo de Impacto | Descrição e Risco | Ação Necessária |
|---|---|---|---|
| `src/soma.js` | novo | Primeiro arquivo de código do repositório. Risco baixo: arquivo isolado, sem dependências. | Criar conforme Interfaces Principais |
| `package.json` | não criado | Sem módulos, sem runner e sem dependências, então não há o que declarar (ADR-006, ADR-007) | Nenhuma |
| `test/` | não criado | Sem testes automatizados (ADR-007) | Nenhuma |
| `prd.md` | divergente | F3, US-004 AC-1/AC-3 e a Restrição de testes não batem com Q1/Q2 | Revisar o PRD com o agente `prd` (fora deste techspec) |

## Abordagem de Testes

- **Sem framework e sem arquivos de teste** (Q2, ADR-007). O contrato de testes abaixo é o catálogo canônico. Cada caso tem entrada e saída exatas para que o revisor, ou uma etapa futura, o execute sem interpretar nada.
- **Harness manual (Node v24), rodado na raiz do repositório.** Carrega o arquivo no contexto global e avalia uma expressão:

```bash
node -e 'require("vm").runInThisContext(require("fs").readFileSync("src/soma.js","utf8"),{filename:"src/soma.js"}); try { console.log(EXPR) } catch (e) { console.log(e.constructor.name + ": " + e.message) }'
```

  Troque `EXPR` pela chamada do caso (ex.: `soma(2, 3)`). A saída esperada de cada caso usa o formato desse comando: o valor impresso por `console.log`, ou `TypeError: <mensagem>`. Para casos com várias instruções, use o REPL: `node`, depois `.load src/soma.js`, e digite as instruções.
- **Níveis:**
  - **UT:** comportamento de `soma` isolado, com todo caminho de erro.
  - **IT:** o limite "arquivo carregado no contexto global ↔ script consumidor", incluindo a limitação do `require`.
  - **E2E:** a jornada do desenvolvedor no terminal, do carregamento à correção de uma chamada errada.
- **Ambiente:** só Node.js ≥ 18 (testado no v24.18.0). Não há dados nem rede.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. `src/soma.js`: declaração, JSDoc, verificação de quantidade, verificação por argumento, `return a + b`. Sem dependências.
2. Execução manual do contrato de testes (UT → IT → E2E) pelo harness. Depende do passo 1.

### Dependências Técnicas

- Node.js instalado (já disponível: v24.18.0) para rodar o harness manual. Nenhuma outra dependência.

## Monitoramento e Observabilidade

Não se aplica: é uma função pura de biblioteca, sem processo em execução, logs ou métricas. A função não escreve no console.

## Considerações Técnicas

### Decisões-Chave

- **Script global, sem módulos** (ADR-006). Arquivo mínimo, que roda em `<script>` e no REPL. Em troca, perde a importação explícita e o `require`.
- **Sem testes automatizados, com contrato manual** (ADR-007). Zero configuração. Em troca, perde a detecção automática de regressões.
- **Validação por `arguments.length` + `typeof` + `Number.isNaN`, com `TypeError` e mensagens fixas em português** (ADR-008). Usa recursos nativos e é previsível. Em troca, quem chama distingue os casos pela mensagem, não por um código.

### Riscos Conhecidos

- **`require` não expõe a função** (probabilidade alta, se alguém tentar). `require("./src/soma.js")` devolve `{}` e não cria `globalThis.soma`. Mitigação: o JSDoc do arquivo diz como carregar, e o caso IT-004 documenta esse comportamento. Se um módulo Node precisar importar a função, a solução é rever a ADR-006.
- **Colisão de nome global** (baixa). Outro script que declare `soma` sobrescreve ou é sobrescrito. Mitigação: o nome é específico, e o repositório não tem outro código.
- **Regressão silenciosa** (média ao longo do tempo). Sem suíte automatizada, uma mudança futura pode quebrar uma regra sem aviso. Mitigação: o catálogo de casos com saídas exatas fica pronto para virar `test/soma.test.js` com `node:test` se a ADR-007 for revista.
- **Leitura literal de RN-08 com `arguments`** (baixa). Em modo estrito, `arguments` não fica ligado aos parâmetros, então ler `arguments.length` não altera nada.

## Divergências com o PRD

| Ponto do PRD | O que o PRD pede | Como fica neste techspec | Origem |
|---|---|---|---|
| F3 / US-004 AC-1 | "Outro módulo importa a função e a chama com 2 e 3 → 5" | Outro **script** carregado no mesmo contexto global chama `soma(2, 3)` → `5`. Não há importação (`import`/`require`). Coberto por IT-001. | Q1, ADR-006 |
| US-004 AC-2 | Erro igual ao de US-002/US-003 no módulo consumidor | Mantido, no script consumidor (IT-002) | — |
| US-004 AC-3 / Restrições Técnicas | Suíte de testes **automatizados** que cobre os casos e passa | Catálogo de casos **documentado** (abaixo), executado à mão pelo harness. Nenhum teste automatizado existe. | Q2, ADR-007 |
| US-004 EC-1 | Funciona sozinha em repositório sem outro código | Mantido (E2E-001) | — |
| US-004 EC-2 | Importação repetida em vários módulos dá o mesmo comportamento | Vira carregamento repetido do script no mesmo contexto (IT-003) | Q1, ADR-006 |

Todas as demais regras e stories (US-001 a US-003, RN-01 a RN-08) ficam cobertas sem mudança.

## Premissas

- O "script global simples" de Q1 roda nos dois ambientes (navegador e Node via `vm`/REPL). O techspec não escolhe um alvo único porque a resposta não restringiu.
- `"use strict"` fica dentro da função (convenção 1) para não afetar outros scripts. É uma decisão técnica sem impacto no comportamento do PRD.
- As mensagens usam o texto exato proposto na Q5 (opção A), sem ponto final.
- O catálogo de testes mantém os IDs `UT`/`IT`/`E2E` e a matriz de cobertura, como o usuário pediu em Q2 ("o techspec traz apenas o catálogo de casos").

## Registro de Decisões Arquiteturais

ADRs de produto (ADR-001 a ADR-005) estão no `prd.md`. ADRs técnicos deste techspec:

- [ADR-006: Script global em `src/soma.js`, sem sistema de módulos](#adr-006-script-global-em-srcsomajs-sem-sistema-de-módulos): declaração `function soma(a, b)` sem export. Diverge da recomendação e do PRD F3/US-004.
- [ADR-007: Sem testes automatizados; contrato de testes documentado](#adr-007-sem-testes-automatizados-contrato-de-testes-documentado): catálogo manual no lugar de suíte. Diverge da recomendação e do PRD US-004 AC-3.
- [ADR-008: Validação nativa com `TypeError` e mensagens fixas em português](#adr-008-validação-nativa-com-typeerror-e-mensagens-fixas-em-português): `arguments.length`, `typeof` e `Number.isNaN`, nessa ordem.

---

# ADRs

## ADR-006: Script global em `src/soma.js`, sem sistema de módulos

### Status
Aceita

### Data
2026-11-13

### Contexto
O repositório não tem código nem `package.json`. A recomendação técnica era CommonJS (`module.exports`), pelo precedente do app removido no commit 7c4356d e pelo PRD (F3, US-004: "exportada para outros módulos"). O usuário respondeu Q1 = "sem módulos: script global simples; `src/soma.js` só declara `function soma(a, b)`, sem `module.exports`/`export`". O nome e o local (`soma` em `src/soma.js`) vêm da Q3 = A.

### Decisão
`src/soma.js` contém só a declaração global `function soma(a, b)` com JSDoc. Não há `module.exports`, `export`, `globalThis.soma = ...`, IIFE nem `package.json`. Outros scripts usam a função carregando o arquivo no mesmo contexto global (`<script>` clássico, `vm.runInThisContext` ou `.load` no REPL do Node).

### Alternativas Consideradas

#### Alternativa 1: CommonJS (recomendação original)
- **Descrição**: `module.exports = { soma }` e `require("./src/soma")`.
- **Prós**: cumpre US-004 AC-1 literalmente e funciona com `require` no Node.
- **Contras**: exige um contrato de módulo que o usuário não quer.
- **Motivo da rejeição**: o usuário escolheu script global (Q1).

#### Alternativa 2: ES Modules
- **Descrição**: `export function soma` e `"type": "module"`.
- **Prós**: padrão moderno, funciona no navegador com `type="module"`.
- **Contras**: exige `package.json` ou a extensão `.mjs`.
- **Motivo da rejeição**: o usuário escolheu sem módulos (Q1).

#### Alternativa 3: Global com `globalThis.soma = soma`
- **Descrição**: declarar e também atribuir ao objeto global, para que `require` exponha a função como efeito colateral.
- **Prós**: funcionaria via `require` no Node.
- **Contras**: vai além de "só declara", e o efeito colateral global ao carregar o arquivo é implícito.
- **Motivo da rejeição**: contraria o esclarecimento da Q1.

### Consequências

#### Positivas
- Arquivo mínimo, sem configuração e sem dependências, que roda direto no navegador.

#### Negativas
- US-004 AC-1 ("importa") é atendido só como "script carregado no mesmo contexto global". O PRD fica divergente até ser revisto.
- `require("./src/soma.js")` não expõe a função (IT-004).

#### Riscos
- Colisão de nome no escopo global. Mitigação: nome específico, e o repositório não tem outro código.

### Notas de Implementação
Não envolva a declaração em nenhum bloco nem função: ela precisa ficar no nível superior do arquivo para virar global.

### Referências
- `techspec.answers.md` Q1 e Q3; `prd.md` F3, US-004; commit 7c4356d.

## ADR-007: Sem testes automatizados; contrato de testes documentado

### Status
Aceita

### Data
2026-11-13

### Contexto
O PRD pede testes automatizados (F3, US-004 AC-3, Restrições Técnicas), e a recomendação era o runner nativo `node:test`. O usuário respondeu Q2 = "sem testes automatizados: sem runner nem arquivos de teste; o techspec traz apenas o catálogo de casos".

### Decisão
Não se cria `test/`, runner, `package.json` nem script `npm test`. O contrato de testes deste documento (UT/IT/E2E + matriz) traz cada caso com entrada e saída exatas. A verificação é manual, pelo harness `node -e` / REPL descrito em Abordagem de Testes.

### Alternativas Consideradas

#### Alternativa 1: `node:test` + `node:assert` (recomendação original)
- **Descrição**: `test/soma.test.js` rodado por `node --test`.
- **Prós**: cumpre US-004 AC-3, detecta regressões e não tem dependências.
- **Contras**: precisa de um arquivo de teste e, com script global, de carregar via `vm`.
- **Motivo da rejeição**: o usuário escolheu sem testes automatizados (Q2).

#### Alternativa 2: Jest ou Vitest
- **Descrição**: framework externo como dependência de desenvolvimento.
- **Prós**: ecossistema rico.
- **Contras**: dependências e configuração para uma função de poucas linhas.
- **Motivo da rejeição**: Q2, e também seria excessivo.

### Consequências

#### Positivas
- Entrega mínima: um único arquivo de código.

#### Negativas
- US-004 AC-3 e a Restrição "testes automatizados são obrigatórios" não são atendidos. O PRD fica divergente até ser revisto.
- Não há proteção automática contra regressão.

#### Riscos
- A verificação manual pode ser pulada ou feita pela metade. Mitigação: cada caso traz o comando e a saída exata, e o catálogo serve de base para automatizar depois.

### Notas de Implementação
A etapa de implementação não cria arquivos de teste. Ela executa o catálogo à mão e registra o resultado (passou/falhou por ID) na entrega.

### Referências
- `techspec.answers.md` Q2; `prd.md` F3, US-004 AC-3, Restrições Técnicas.

## ADR-008: Validação nativa com `TypeError` e mensagens fixas em português

### Status
Aceita

### Data
2026-11-13

### Contexto
O PRD fixa as regras (RN-01 a RN-07), mas não diz como verificá-las nem que erro lançar. O usuário escolheu `TypeError` em todos os casos (Q4 = A) e mensagens fixas em português (Q5 = A).

### Decisão
Na ordem: `arguments.length !== 2`, depois `typeof x !== "number"` e `Number.isNaN(x)` para o 1º argumento e em seguida para o 2º. Toda recusa lança `TypeError` com uma das mensagens fixas da tabela em Interfaces Principais. Nenhuma conversão de valor.

### Alternativas Consideradas

#### Alternativa 1: `RangeError` para quantidade
- **Descrição**: separar quantidade (`RangeError`) de tipo (`TypeError`).
- **Prós**: distingue a causa pelo tipo do erro.
- **Contras**: dois tipos para tratar.
- **Motivo da rejeição**: Q4 = A.

#### Alternativa 2: Classe `SomaError` com `code`
- **Descrição**: erro próprio com códigos estáveis.
- **Prós**: o chamador distingue os casos sem ler a mensagem.
- **Contras**: precisaria de outro símbolo global, e ninguém pediu.
- **Motivo da rejeição**: Q4 = A.

#### Alternativa 3: Checar com `Number.isFinite`
- **Descrição**: uma única checagem para `NaN`, tipo e infinitos.
- **Prós**: mais curta.
- **Contras**: recusaria `Infinity`, contra a RN-04, e não distingue `NaN` de não-número (RN-06).
- **Motivo da rejeição**: viola o PRD.

### Consequências

#### Positivas
- `typeof` recusa `BigInt`, `new Number(...)`, `null` e os demais sem ramos extras. `Number.isNaN` não converte.
- Mensagens previsíveis, que viram asserções exatas.

#### Negativas
- Quem chama distingue os casos só pelo texto da mensagem.

#### Riscos
- Mudar o texto de uma mensagem quebra o contrato de testes. Mitigação: as mensagens estão fixadas aqui.

### Referências
- `techspec.answers.md` Q4 e Q5; `prd.md` RN-01 a RN-07, ADR-002, ADR-005.

---

# Especificação de Testes: Função de soma de dois números

Contrato de teste canônico da issue #3. Complementa o TechSpec acima. Derivado do Catálogo de User Stories do `prd.md` (comportamento) e deste TechSpec (componentes). Os testes são manuais (ADR-007).

## Estratégia

- **Harness:** o comando `node -e` da seção Abordagem de Testes, com `EXPR` trocado pela expressão do caso, ou o REPL (`node`, `.load src/soma.js`) para casos com várias instruções. Rode na raiz do repositório.
- **Saída esperada:** o formato impresso pelo harness, ou seja, o valor (`5`, `Infinity`, `NaN`, `true`) ou `TypeError: <mensagem exata>`.
- **Convenção de erro:** todo caso `error` exige, juntos, a classe `TypeError` (`e.constructor === TypeError`) e a mensagem idêntica caractere por caractere.
- **Registro:** a etapa de implementação lista cada ID com "passou" ou "falhou".

## Matriz de Cobertura

| Fonte | Comportamento | Unitário | Integração | E2E |
|---|---|---|---|---|
| US-001 | Soma de dois números válidos | UT-001–UT-006 | IT-001 | E2E-001 |
| US-001.EC-1 | `Infinity + -Infinity` → `NaN` nativo | UT-007 | — | — |
| US-001.EC-2 | Estouro → `Infinity` | UT-008 | — | — |
| US-001.EC-3 | `0 + -0` → `0` | UT-009 | — | — |
| US-001.EC-4 | `MAX_SAFE_INTEGER + 2` nativo | UT-010 | — | — |
| US-001.EC-5 | Chamadas repetidas/simultâneas independentes | UT-011 | — | — |
| US-002 | Recusa de argumento não numérico / `NaN` | UT-012–UT-017, UT-031 | IT-002 | E2E-002 |
| US-002.EC-1 | `null` / `undefined` | UT-018, UT-019 | — | — |
| US-002.EC-2 | Booleanos | UT-020, UT-021 | — | — |
| US-002.EC-3 | Texto vazio / só espaços | UT-022, UT-023 | — | — |
| US-002.EC-4 | Objeto, array, função | UT-024–UT-026 | — | — |
| US-002.EC-5 | `new Number(2)` | UT-027 | — | — |
| US-002.EC-6 | Dois inválidos → cita o primeiro | UT-028 | — | — |
| US-002.EC-7 | `10n, 10n` | UT-029 | — | — |
| US-002.EC-8 | Argumentos não alterados ao lançar erro | UT-030 | — | — |
| US-003 | Quantidade errada | UT-032–UT-034 | — | E2E-003 |
| US-003.EC-1 | Quantidade e tipo errados → erro de quantidade | UT-035 | — | — |
| US-003.EC-2 | `undefined` explícito no 2º → erro de tipo | UT-036 | — | — |
| US-003.EC-3 | 100 argumentos | UT-037 | — | — |
| US-004 | Uso por outro script (adaptado, ADR-006) | — | IT-001, IT-002 | E2E-001 |
| US-004.AC-3 | Suíte automatizada (substituída pelo catálogo manual, ADR-007) | todos os UT | todos os IT | todos os E2E |
| US-004.EC-1 | Funciona sozinha, sem outro código | — | — | E2E-001 |
| US-004.EC-2 | Carregamento repetido, mesmo comportamento | — | IT-003 | — |
| Componente `soma`: classe do erro | Sempre `TypeError` | UT-038 | — | — |
| Componente `soma`: sem estado | Erro não afeta a chamada seguinte | UT-039 | — | — |
| Componente `src/soma.js`: sem export | `require` não expõe a função | — | IT-004 | — |

## Testes Unitários

### `soma` — soma válida (TechSpec: Interfaces Principais, passo 3)

- **UT-001** (happy): `soma(2, 3)` imprime `5`.
- **UT-002** (happy): `soma(-4, 1)` imprime `-3`.
- **UT-003** (happy): `soma(0, 7)` imprime `7`.
- **UT-004** (boundary): `soma(0.1, 0.2) === 0.30000000000000004` imprime `true` (sem arredondamento).
- **UT-005** (boundary): `soma(Infinity, 1)` imprime `Infinity`.
- **UT-006** (idempotency): `soma(0.1, 0.2) === soma(0.1, 0.2)` imprime `true`.
- **UT-007** (boundary): `Number.isNaN(soma(Infinity, -Infinity))` imprime `true`, sem erro lançado.
- **UT-008** (boundary): `soma(Number.MAX_VALUE, Number.MAX_VALUE)` imprime `Infinity`, sem erro.
- **UT-009** (boundary): `Object.is(soma(0, -0), 0)` imprime `true`.
- **UT-010** (boundary): `soma(Number.MAX_SAFE_INTEGER, 2)` imprime `9007199254740992` (resultado nativo impreciso, sem erro).
- **UT-011** (concurrency): `Promise.all(Array.from({length: 1000}, (_, i) => Promise.resolve().then(() => i % 2 ? soma(1, 2) : soma(3, 4)))).then(r => console.log(r.every((v, i) => v === (i % 2 ? 3 : 7))))` imprime `true`. Rode no REPL depois de `.load src/soma.js`.

### `soma` — recusa de tipo e `NaN` (TechSpec: Interfaces Principais, passo 2.2)

- **UT-012** (error): `soma("2", 3)` imprime `TypeError: soma: o primeiro argumento não é um número`.
- **UT-013** (error): `soma(2, "3")` imprime `TypeError: soma: o segundo argumento não é um número`.
- **UT-014** (error): `soma(NaN, 1)` imprime `TypeError: soma: o primeiro argumento é NaN`.
- **UT-015** (error): `soma(1, NaN)` imprime `TypeError: soma: o segundo argumento é NaN`.
- **UT-016** (error): `soma(10n, 1)` imprime `TypeError: soma: o primeiro argumento não é um número`.
- **UT-017** (error): `soma(1, 10n)` imprime `TypeError: soma: o segundo argumento não é um número`.
- **UT-018** (error): `soma(null, 1)` imprime `TypeError: soma: o primeiro argumento não é um número`.
- **UT-019** (error): `soma(1, undefined)` imprime `TypeError: soma: o segundo argumento não é um número`.
- **UT-020** (error): `soma(true, 1)` imprime `TypeError: soma: o primeiro argumento não é um número`.
- **UT-021** (error): `soma(1, false)` imprime `TypeError: soma: o segundo argumento não é um número`.
- **UT-022** (error): `soma("", 1)` imprime `TypeError: soma: o primeiro argumento não é um número`.
- **UT-023** (error): `soma(1, "  ")` imprime `TypeError: soma: o segundo argumento não é um número`.
- **UT-024** (error): `soma({}, 1)` imprime `TypeError: soma: o primeiro argumento não é um número`.
- **UT-025** (error): `soma(1, [1])` imprime `TypeError: soma: o segundo argumento não é um número`.
- **UT-026** (error): `soma(function () {}, 1)` imprime `TypeError: soma: o primeiro argumento não é um número`.
- **UT-027** (error): `soma(new Number(2), 1)` imprime `TypeError: soma: o primeiro argumento não é um número`.
- **UT-028** (ordering): `soma("a", "b")` imprime `TypeError: soma: o primeiro argumento não é um número`.
- **UT-029** (error): `soma(10n, 10n)` imprime `TypeError: soma: o primeiro argumento não é um número`.
- **UT-030** (state): no REPL, `const o = {v: 1}; const a = [1]; try { soma(o, a) } catch {}; console.log(JSON.stringify([o, a]))` imprime `[{"v":1},[1]]`.
- **UT-031** (ordering): `soma(NaN, "b")` imprime `TypeError: soma: o primeiro argumento é NaN`.

### `soma` — recusa de quantidade (TechSpec: Interfaces Principais, passo 2.1)

- **UT-032** (error): `soma()` imprime `TypeError: soma: esperados exatamente 2 argumentos, recebidos 0`.
- **UT-033** (error): `soma(5)` imprime `TypeError: soma: esperados exatamente 2 argumentos, recebidos 1`.
- **UT-034** (error): `soma(1, 2, 3)` imprime `TypeError: soma: esperados exatamente 2 argumentos, recebidos 3`.
- **UT-035** (ordering): `soma("a")` imprime `TypeError: soma: esperados exatamente 2 argumentos, recebidos 1`.
- **UT-036** (boundary): `soma(2, undefined)` imprime `TypeError: soma: o segundo argumento não é um número`.
- **UT-037** (boundary): `soma(...Array(100).fill(1))` imprime `TypeError: soma: esperados exatamente 2 argumentos, recebidos 100`.

### `soma` — propriedades do componente

- **UT-038** (error): `(() => { try { soma("x", 1) } catch (e) { return e.constructor === TypeError && e.name === "TypeError" } })()` imprime `true`.
- **UT-039** (state): no REPL, `try { soma("a", 1) } catch {}; soma(2, 3)` devolve `5`.

## Testes de Integração

### Arquivo carregado no contexto global ↔ script consumidor

- **IT-001**: `node -e 'const vm = require("vm"), fs = require("fs"); vm.runInThisContext(fs.readFileSync("src/soma.js","utf8")); vm.runInThisContext("console.log(typeof soma, soma(2, 3))")'` imprime `function 5`. O segundo `runInThisContext` faz o papel do script consumidor.
- **IT-002**: mesmo comando do IT-001, com o consumidor `"try { soma(\"2\", 3) } catch (e) { console.log(e.constructor.name + \": \" + e.message) }"`, imprime `TypeError: soma: o primeiro argumento não é um número`.
- **IT-003**: carregar `src/soma.js` duas vezes seguidas com `vm.runInThisContext` e depois executar `console.log(soma(2, 3))` imprime `5`, sem erro de redeclaração.
- **IT-004**: `node -e 'console.log(JSON.stringify(require("./src/soma.js")), typeof globalThis.soma)'` imprime `{} undefined`. Isso confirma que não há export nem atribuição global por efeito colateral (ADR-006).

## Testes Ponta a Ponta

### Desenvolvedor usa a função num repositório sem outro código (US-001, US-004)

- **E2E-001**: num clone limpo (só `src/soma.js` como código), na raiz, rode o harness com `EXPR = soma(2, 3)`. O comando imprime `5` e termina com código de saída 0.

### Desenvolvedor erra o tipo e corrige (US-002)

- **E2E-002**: no REPL (`node`, `.load src/soma.js`), digite `soma("2", 3)`. O REPL mostra `Uncaught TypeError: soma: o primeiro argumento não é um número`. Em seguida digite `soma(2, 3)`, e o REPL mostra `5`.

### Desenvolvedor erra a quantidade e corrige (US-003)

- **E2E-003**: no REPL, depois de `.load src/soma.js`, digite `soma(1, 2, 3)`. O REPL mostra `Uncaught TypeError: soma: esperados exatamente 2 argumentos, recebidos 3`. Em seguida digite `soma(1, 2)`, e o REPL mostra `3`.
