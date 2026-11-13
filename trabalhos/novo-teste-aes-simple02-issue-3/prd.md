VERDICT: DONE

# PRD: Função de soma de dois números (issue #3)

## Resumo

- **O quê:** uma função JavaScript que recebe exatamente dois números e devolve a soma deles pela aritmética nativa, recusando com erro claro qualquer entrada que não seja um número válido.
- **Para quem:** desenvolvedores que escrevem outros módulos deste repositório e precisam somar dois valores com segurança.
- **Por que agora:** a issue #3 pede a função, e o repositório não tem hoje nenhum código de aplicação nem utilitário de soma.

## Visão Geral

O operador `+` do JavaScript soma números, mas também concatena textos e converte tipos sem avisar. Com ele, `"2" + 3` vira `"23"` e `2 + undefined` vira `NaN`, e esses resultados errados passam sem erro. A função de soma resolve isso para quem a importa: devolve a soma nativa quando recebe dois números válidos e para com um erro claro quando recebe outra coisa.

A função é para os desenvolvedores deste repositório. O valor está em ter um único ponto confiável para somar dois números, com regras de entrada explícitas e testadas.

## Objetivos

- Um módulo do repositório importa a função e obtém a soma de dois números pela aritmética nativa do JavaScript, sem arredondamento.
- A função garante que só soma números válidos. Texto, valores ausentes, `NaN`, `BigInt`, objetos e quantidade errada de argumentos são recusados com uma mensagem que diz o que está errado.
- Deixa de ser possível obter da função uma concatenação de texto ou um `NaN` silencioso.

## User Stories

Catálogo completo na seção [Catálogo de User Stories](#catálogo-de-user-stories) deste arquivo.

- US-001: soma de dois números válidos.
- US-002 a US-003: recusa de entradas inválidas (tipo e quantidade).
- US-004: uso da função por outros módulos do repositório.

## Funcionalidades Principais

### F1. Somar dois números
- Recebe dois valores e, se ambos forem números válidos (ver Regras de Negócio), devolve `a + b` pela aritmética nativa do JavaScript.
- Não arredonda nem corrige precisão: `0.1 + 0.2` devolve `0.30000000000000004`.
- Aceita inteiros, negativos, zero, decimais e infinitos.
- Não altera os valores recebidos e não tem efeitos colaterais. Os mesmos valores sempre produzem o mesmo resultado.

### F2. Validar as entradas
- Antes de somar, verifica a quantidade de argumentos e o tipo de cada um.
- Quando alguma regra é violada, a função não devolve resultado: ela lança um erro com mensagem clara que diz qual entrada é inválida (primeira ou segunda) ou que a quantidade de argumentos está errada.

### F3. Disponibilizar para outros módulos
- A função é exportada para que outros módulos do repositório possam importá-la.
- Vem com testes automatizados que cobrem os critérios de aceite deste PRD.

Interação: F2 roda sempre antes de F1. F3 expõe o conjunto F1 + F2.

## Regras de Negócio

- **RN-01 Quantidade:** a função exige exatamente 2 argumentos. Com 0, 1, 3 ou mais, ela recusa com erro que informa que são esperados exatamente dois números. (ADR-003)
- **RN-02 Tipo:** cada argumento precisa ser um número primitivo do JavaScript. São recusados texto (inclusive texto numérico como `"2"`), `undefined`, `null`, booleanos, objetos, arrays, funções, `BigInt` e objetos `Number` criados com `new Number(...)`. (ADR-001, ADR-005)
- **RN-03 NaN:** `NaN` é recusado com erro, embora seja do tipo número. (ADR-002)
- **RN-04 Infinitos:** `Infinity` e `-Infinity` são aceitos, e o resultado é o nativo (ex.: `Infinity + 1 = Infinity`, `Infinity + -Infinity = NaN`). Quando os dois infinitos de sinais opostos geram `NaN`, a função devolve esse `NaN` nativo. Essa é a única situação em que a função devolve `NaN`, e ela segue da RN-05. (ADR-002)
- **RN-05 Aritmética nativa:** o resultado é exatamente `a + b` do JavaScript, sem arredondamento, sem conversão e sem limite próprio. Um estouro de magnitude (ex.: `Number.MAX_VALUE + Number.MAX_VALUE`) devolve `Infinity`, como na aritmética nativa.
- **RN-06 Mensagem de erro:** a mensagem diz qual argumento falhou (primeiro ou segundo) e por quê (não é número, é `NaN`), ou que a quantidade está errada. Se os dois argumentos forem inválidos, a mensagem cita ao menos o primeiro que falhar.
- **RN-07 Ordem das verificações:** a quantidade de argumentos é verificada antes do tipo.
- **RN-08 Pureza:** a função não modifica os argumentos, não guarda estado entre chamadas e é determinística.

## Experiência do Usuário

- **Persona principal:** desenvolvedor do repositório que escreve um módulo e precisa somar dois valores.
- **Fluxo principal:** (1) importa a função no seu módulo; (2) chama com dois números; (3) recebe a soma.
- **Fluxo de erro:** (1) chama com um valor inválido; (2) recebe um erro cuja mensagem aponta o argumento e o motivo; (3) corrige a chamada.
- **Descobribilidade:** o nome da função e a documentação junto ao código deixam claro que ela soma exatamente dois números e recusa entradas que não sejam números.
- Não há interface de usuário.

## Restrições Técnicas de Alto Nível

- Linguagem: JavaScript (pedido explícito da issue).
- O repositório não tem hoje nenhum código de aplicação, então não há integração obrigatória com módulos existentes.
- Testes automatizados são obrigatórios e devem cobrir pelo menos inteiros, negativos, zero, decimais (`0.1 + 0.2`), infinitos e cada classe de entrada recusada.
- Sem requisitos de performance, privacidade ou conformidade além do comportamento descrito.

## Não-Objetivos (Fora de Escopo)

- CLI, interface web ou endpoint HTTP (escopo do intake).
- Outras operações, como subtração e multiplicação (escopo do intake).
- Somar mais de dois números: chamadas com mais de dois argumentos são recusadas (escopo do intake e Q3).
- Precisão decimal arbitrária ou arredondamento (escopo do intake).
- Conversão de texto numérico para número (Q1 = A).
- Suporte a `BigInt` (Q5 = A).
- Publicação como pacote para outros projetos (Q4 = A).

## Registro de Decisões de Produto

- [ADR-001](#adr-001-recusar-entradas-que-não-são-número) Recusar com erro claro qualquer entrada que não seja número, sem converter.
- [ADR-002](#adr-002-recusar-nan-e-aceitar-infinitos) Recusar `NaN` e aceitar `Infinity`/`-Infinity`.
- [ADR-003](#adr-003-exigir-exatamente-dois-argumentos) Exigir exatamente dois argumentos.
- [ADR-004](#adr-004-uso-interno-ao-repositório) Uso interno ao repositório, sem publicar pacote.
- [ADR-005](#adr-005-bigint-tratado-como-entrada-inválida) `BigInt` tratado como entrada inválida.

## Glossário

| Termo | Definição |
|---|---|
| Aritmética nativa | O resultado do operador `+` do JavaScript entre dois números, em ponto flutuante de dupla precisão (IEEE 754), sem arredondamento extra. |
| Número primitivo | Valor cujo `typeof` é `"number"`. Não inclui objetos `new Number(...)` nem `BigInt`. |
| Número válido | Número primitivo diferente de `NaN`. Inclui `Infinity` e `-Infinity`. |
| `NaN` | "Not a Number": valor especial do tipo número que representa um resultado indefinido. |
| `BigInt` | Tipo do JavaScript para inteiros de tamanho arbitrário (ex.: `10n`). |
| Argumento | Cada valor passado na chamada da função. |

## Premissas

As respostas do usuário (Q1 a Q5, todas na opção recomendada A) estão nos ADRs. Decidi os pontos abaixo sem pergunta, porque são desdobramentos diretos dessas respostas:

- Objetos `new Number(...)` são recusados (desdobramento de Q1: só números primitivos).
- Uma chamada com dois argumentos em que um deles é `undefined` explícito é recusada pela RN-02 (tipo), não pela RN-01 (quantidade).
- `Infinity + -Infinity` devolve o `NaN` nativo em vez de erro, porque as duas entradas são válidas e a regra é aritmética nativa (Q2 = A).
- Quando os dois argumentos são inválidos, a mensagem cita ao menos o primeiro.

## Perguntas em Aberto

- Nenhuma.

---

# Catálogo de User Stories

Catálogo canônico de comportamento da função de soma. Complementa o PRD acima e é consumido pelo techspec (mapeamento de componentes) e pelos testes (matriz de cobertura).

## Resumo

| Story | Critério de Aceite Principal |
|---|---|
| US-001: Somar dois números | Dois números válidos devolvem a soma nativa, sem arredondar. |
| US-002: Recusar argumento que não é número válido | Texto, `null`, `undefined`, booleano, objeto, `BigInt` ou `NaN` geram erro que aponta o argumento. |
| US-003: Recusar quantidade errada de argumentos | Com menos ou mais de dois argumentos, a função gera erro de quantidade. |
| US-004: Importar a função em outro módulo | Outro módulo do repositório importa a função e obtém o mesmo comportamento. |

## Personas

- **Desenvolvedor do repositório:** escreve outros módulos deste repositório e precisa somar dois valores de forma confiável, com erro claro quando passar algo errado.
- **Dono do repositório (revisor):** revisa a entrega e precisa verificar, pelos testes, que cada regra deste PRD é cumprida.

## Índice de Stories

| ID | Área da Funcionalidade | Persona | Story |
|---|---|---|---|
| US-001 | Soma | Desenvolvedor | Somar dois números válidos e receber a soma nativa. |
| US-002 | Validação | Desenvolvedor | Receber erro claro ao passar um argumento que não é número válido. |
| US-003 | Validação | Desenvolvedor | Receber erro claro ao passar quantidade errada de argumentos. |
| US-004 | Disponibilização | Desenvolvedor / Revisor | Importar a função de outro módulo, com testes que comprovam o comportamento. |

## Soma

### US-001: Somar dois números

**Como** desenvolvedor do repositório, **eu quero** passar dois números para a função, **para que** eu receba a soma deles sem me preocupar com conversões silenciosas.

Critérios de aceite:

- AC-1: Dado `2` e `3`, quando a função é chamada, então devolve `5`.
- AC-2: Dado `-4` e `1`, quando a função é chamada, então devolve `-3`.
- AC-3: Dado `0` e `7`, quando a função é chamada, então devolve `7`.
- AC-4: Dado `0.1` e `0.2`, quando a função é chamada, então devolve `0.30000000000000004` (resultado nativo, sem arredondar).
- AC-5: Dado `Infinity` e `1`, quando a função é chamada, então devolve `Infinity`.
- AC-6: Dados quaisquer dois números válidos, quando a função é chamada duas vezes com os mesmos valores, então devolve o mesmo resultado nas duas vezes.

Casos de borda:

- EC-1: `Infinity` e `-Infinity` → devolve `NaN` (resultado nativo; as entradas são válidas).
- EC-2: `Number.MAX_VALUE` e `Number.MAX_VALUE` → devolve `Infinity` (estouro nativo, sem erro).
- EC-3: `0` e `-0` → devolve `0` (resultado nativo).
- EC-4: `Number.MAX_SAFE_INTEGER` e `2` → devolve o resultado nativo, mesmo que impreciso, sem erro nem ajuste.
- EC-5: Repetição e concorrência: chamadas repetidas ou simultâneas não interferem entre si, porque a função não guarda estado.

## Validação

### US-002: Recusar argumento que não é número válido

**Como** desenvolvedor do repositório, **eu quero** receber um erro claro quando passo algo que não é número, **para que** eu não receba concatenação de texto nem `NaN` silencioso.

Critérios de aceite:

- AC-1: Dado `"2"` e `3`, quando a função é chamada, então lança erro cuja mensagem indica que o primeiro argumento não é número, e não devolve `"23"` nem `5`.
- AC-2: Dado `2` e `"3"`, quando a função é chamada, então lança erro cuja mensagem indica que o segundo argumento não é número.
- AC-3: Dado `NaN` em qualquer posição, quando a função é chamada, então lança erro cuja mensagem indica que aquele argumento é `NaN`.
- AC-4: Dado `10n` (`BigInt`) em qualquer posição, quando a função é chamada, então lança erro de argumento que não é número.

Casos de borda:

- EC-1: `null` ou `undefined` em qualquer posição → erro que aponta o argumento.
- EC-2: `true`/`false` → erro, sem converter para `1`/`0`.
- EC-3: Texto vazio `""` ou só com espaços → erro que aponta o argumento.
- EC-4: Objeto, array (ex.: `[1]`) ou função → erro que aponta o argumento.
- EC-5: `new Number(2)` → erro (não é número primitivo).
- EC-6: Os dois argumentos inválidos (ex.: `"a"`, `"b"`) → erro que cita ao menos o primeiro argumento.
- EC-7: `10n` e `10n` → erro (`BigInt` não é aceito nem quando os dois são `BigInt`).
- EC-8: Os argumentos recebidos não são alterados, nem quando a função lança erro.

### US-003: Recusar quantidade errada de argumentos

**Como** desenvolvedor do repositório, **eu quero** receber um erro quando chamo a função com menos ou mais de dois valores, **para que** um uso errado (esquecer um valor ou tentar somar três) não passe despercebido.

Critérios de aceite:

- AC-1: Dada uma chamada sem argumentos, quando executada, então lança erro informando que são esperados exatamente dois números.
- AC-2: Dada uma chamada com um único número (ex.: `5`), quando executada, então lança o mesmo erro de quantidade.
- AC-3: Dada uma chamada com três números (ex.: `1, 2, 3`), quando executada, então lança o erro de quantidade e não devolve `3` nem `6`.

Casos de borda:

- EC-1: Quantidade errada e tipo errado ao mesmo tempo (ex.: só `"a"`) → o erro relatado é o de quantidade (RN-07).
- EC-2: Dois argumentos em que o segundo é `undefined` explícito → erro de tipo do segundo argumento (US-002), não de quantidade.
- EC-3: Muitos argumentos (ex.: 100) → mesmo erro de quantidade.

## Disponibilização

### US-004: Importar a função em outro módulo

**Como** desenvolvedor do repositório, **eu quero** importar a função de soma no meu módulo, **para que** eu reutilize o mesmo comportamento validado em vez de reescrever a soma.

**Como** dono do repositório, **eu quero** testes automatizados que cubram cada critério deste catálogo, **para que** eu verifique a entrega sem testar à mão.

Critérios de aceite:

- AC-1: Dado outro módulo do repositório, quando ele importa a função e a chama com `2` e `3`, então recebe `5`.
- AC-2: Dado o módulo importador, quando chama a função com uma entrada inválida, então recebe o mesmo erro descrito em US-002/US-003.
- AC-3: Dada a suíte de testes automatizados, quando executada, então cobre pelo menos inteiros, negativos, zero, `0.1 + 0.2`, infinitos, cada classe de entrada recusada de US-002 e a quantidade errada de US-003, e todos os testes passam.

Casos de borda:

- EC-1: Primeira execução em um repositório sem nenhum outro código → a função e seus testes funcionam sozinhos, sem depender de outros módulos.
- EC-2: Importação repetida em vários módulos → todos obtêm o mesmo comportamento (não há estado compartilhado).

---

# ADRs

## ADR-001: Recusar entradas que não são número

**Decisão:** a função recusa com erro claro qualquer argumento que não seja número primitivo, sem tentar converter.

### Status
Aceita

### Data
2026-11-13

### Contexto
A issue não diz o que fazer com entradas que não são números. O `+` nativo concatena textos e converte tipos sem avisar. O intake adotou a leitura "rejeitar com erro claro", e o usuário confirmou (Q1 = A).

### Decisão
Só números primitivos são aceitos. Texto, inclusive texto numérico, `null`, `undefined`, booleanos, objetos, arrays, funções e `new Number(...)` geram erro que aponta o argumento.

### Alternativas Consideradas

#### Alternativa 1: Converter texto numérico
- **Descrição**: aceitar `"2"` como `2`.
- **Prós**: mais tolerante com dados vindos de formulários.
- **Contras**: regras de conversão ambíguas (`""`, `" "`, `"1e3"`) e erros escondidos.
- **Motivo da rejeição**: o usuário escolheu a recusa (Q1 = A).

#### Alternativa 2: Comportamento nativo sem validação
- **Descrição**: devolver `a + b` com qualquer entrada.
- **Prós**: mais simples.
- **Contras**: `"2" + 3 = "23"` e `NaN` silenciosos.
- **Motivo da rejeição**: contraria o propósito de somar números com segurança.

### Consequências
- Positivas: erros de uso aparecem na hora, com mensagem clara.
- Negativas: quem tem texto numérico precisa convertê-lo antes de chamar a função.
- Riscos: nenhum relevante; o escopo é contido.

### Referências
- Issue #3; `intake.md` (Scope); `prd.answers.md` Q1.

## ADR-002: Recusar NaN e aceitar infinitos

**Decisão:** `NaN` é recusado com erro; `Infinity` e `-Infinity` são aceitos e somados de forma nativa.

### Status
Aceita

### Data
2026-11-13

### Contexto
`NaN` e os infinitos são do tipo número. Era preciso decidir se contam como "número válido" (Q2 = A).

### Decisão
`NaN` na entrada gera erro. Infinitos são aceitos, e o resultado segue a aritmética nativa, inclusive `Infinity + -Infinity = NaN`.

### Alternativas Consideradas

#### Alternativa 1: Recusar também os infinitos
- **Prós**: o resultado é sempre um número finito quando as entradas são finitas.
- **Contras**: infinito é um valor numérico legítimo, e o escopo pede aritmética nativa.
- **Motivo da rejeição**: o usuário escolheu A.

#### Alternativa 2: Aceitar NaN
- **Prós**: comportamento 100% nativo.
- **Contras**: propaga erro em silêncio.
- **Motivo da rejeição**: contraria ADR-001.

### Consequências
- Positivas: o caso mais comum de dado corrompido (`NaN`) é barrado.
- Negativas: `Infinity + -Infinity` ainda devolve `NaN`, o que é aceito por coerência com a aritmética nativa.
- Riscos: nenhum relevante.

### Referências
- `prd.answers.md` Q2.

## ADR-003: Exigir exatamente dois argumentos

**Decisão:** chamadas com menos ou mais de dois argumentos são recusadas com erro de quantidade, verificado antes do tipo.

### Status
Aceita

### Data
2026-11-13

### Contexto
A issue fala em "2 números", e somar mais de dois está fora do escopo. Era preciso decidir o que fazer com argumentos faltantes ou extras (Q3 = A).

### Decisão
A função exige exatamente dois argumentos. A quantidade é verificada antes do tipo, para que a mensagem aponte a causa mais básica.

### Alternativas Consideradas

#### Alternativa 1: Ignorar argumentos extras
- **Prós**: tolerante, como o JavaScript nativo.
- **Contras**: `soma(1, 2, 3)` devolveria `3` em silêncio.
- **Motivo da rejeição**: o usuário escolheu A.

### Consequências
- Positivas: uso errado (tentar somar três valores) é detectado.
- Negativas: nenhuma relevante.
- Riscos: nenhum.

### Referências
- `prd.answers.md` Q3.

## ADR-004: Uso interno ao repositório

**Decisão:** a função é exportada para outros módulos deste repositório; publicar como pacote fica fora do escopo.

### Status
Aceita

### Data
2026-11-13

### Contexto
O intake pede "exportável para outros módulos". Era preciso saber se isso inclui publicar um pacote (Q4 = A).

### Decisão
Só uso interno ao repositório.

### Alternativas Consideradas

#### Alternativa 1: Publicar como pacote
- **Prós**: reutilizável por outros projetos.
- **Contras**: exige nome, versionamento e publicação, que ninguém pediu.
- **Motivo da rejeição**: o usuário escolheu A.

### Consequências
- Positivas: escopo pequeno, que cabe em um PR.
- Negativas: outros projetos não podem reutilizar a função diretamente.
- Riscos: nenhum.

### Referências
- `intake.md` (Scope); `prd.answers.md` Q4.

## ADR-005: BigInt tratado como entrada inválida

**Decisão:** valores `BigInt` são recusados pela mesma regra de entrada inválida, inclusive quando os dois argumentos são `BigInt`.

### Status
Aceita

### Data
2026-11-13

### Contexto
O escopo exclui precisão arbitrária. Misturar `BigInt` com número comum gera erro no próprio JavaScript (Q5 = A).

### Decisão
`BigInt` em qualquer posição gera erro de argumento que não é número.

### Alternativas Consideradas

#### Alternativa 1: Aceitar dois BigInt
- **Prós**: soma inteiros gigantes com exatidão.
- **Contras**: dois tipos de retorno e regras extras de mistura.
- **Motivo da rejeição**: o usuário escolheu A; o escopo exclui precisão arbitrária.

### Consequências
- Positivas: um único tipo de entrada e de retorno.
- Negativas: quem trabalha com `BigInt` precisa somar por conta própria.
- Riscos: nenhum.

### Referências
- `intake.md` (Scope); `prd.answers.md` Q5.
