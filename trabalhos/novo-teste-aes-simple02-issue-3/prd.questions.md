# Perguntas do PRD: issue 3 (rodada 1)

Contexto da pesquisa:
- Issue #3: "criar a soma de 2 números em javascript de uma função que soma". Sem comentários.
- Código: o repositório não versiona nenhum arquivo de aplicação; não há função de soma nem convenção de código para seguir.
- Mercado: bibliotecas utilitárias conhecidas (ex.: `lodash.add`) somam com a aritmética nativa e não arredondam; diferem no tratamento de entradas inválidas (algumas convertem, outras devolvem `NaN`). Por isso as decisões abaixo cabem a você.

Responda com o número e a letra (ex.: `Q1: A`). Se aceitar todas as recomendações, basta responder "todas as recomendações".

## Q1. O que a função faz quando recebe algo que não é número (texto, vazio, objeto)?
**Recomendação: A, porque** o intake já adotou essa leitura e um erro claro evita resultados silenciosamente errados (ex.: `"2" + 3` virar `"23"`).
- A) Recusa com uma mensagem de erro clara dizendo qual entrada é inválida.
- B) Tenta converter texto numérico (ex.: `"2"` vira `2`) e recusa só o que não der para converter.
- C) Não valida: segue o comportamento nativo do JavaScript, seja qual for o resultado.
- D) Outro: descreva.

## Q2. E os valores especiais do tipo número: `NaN` e `Infinity`?
**Recomendação: A, porque** `NaN` significa "não é um número" e somá-lo só propaga erro; já o infinito é um valor numérico válido e a regra de "aritmética nativa" do escopo o cobre.
- A) Recusa `NaN` com erro; aceita `Infinity`/`-Infinity` e devolve o resultado nativo.
- B) Recusa os dois (`NaN` e infinitos).
- C) Aceita os dois e devolve o resultado nativo.
- D) Outro: descreva.

## Q3. O que acontece se a função for chamada com menos ou mais de dois valores?
**Recomendação: A, porque** a issue fala em "2 números"; faltar um é entrada inválida, e somar mais de dois está fora do escopo, então ignorar extras em silêncio esconderia um uso errado.
- A) Exige exatamente dois: recusa com erro se faltar algum ou se vierem a mais.
- B) Recusa se faltar algum; ignora valores extras.
- C) Outro: descreva.

## Q4. Quem vai usar a função?
**Recomendação: A, porque** o escopo do intake fala em "exportável para outros módulos" e publicar um pacote traria trabalho (nome, versão, publicação) que ninguém pediu.
- A) Outros módulos deste repositório (uso interno); publicação como pacote fica fora do escopo.
- B) Também deve ser publicada como pacote reutilizável por outros projetos.
- C) Outro: descreva.

## Q5. A função precisa aceitar inteiros gigantes do tipo `BigInt` (ex.: `10n`)?
**Recomendação: A, porque** o escopo exclui precisão arbitrária e misturar `BigInt` com número comum gera erro no próprio JavaScript.
- A) Não: `BigInt` é tratado como entrada inválida (mesma regra da Q1).
- B) Sim: aceita dois `BigInt` e devolve um `BigInt`; misturar os dois tipos é recusado.
- C) Outro: descreva.
