DECISION: ACCEPT
RISK: low
SURFACES: none
RESCOPED: no
ROUTE: feature

## Summary
- A issue #3 pede uma função em JavaScript que some dois números; o pedido é curto, mas a leitura é clara.
- Não há duplicidade: buscas por "soma" e "sum" em issues e PRs (abertos e fechados) só retornam a própria #3; a #1 e o PR #2 tratavam de um servidor Express.
- O repositório não tem código de aplicação hoje: o commit 7c4356d removeu `package.json`, `src/` e `test/`, então não existe nenhuma função de soma.
- Aceito como funcionalidade nova pequena, com teste automatizado incluído.

## Scope
Construir:
- Uma função JavaScript, exportada para que outros módulos e os testes possam importá-la, que recebe dois números e retorna a soma deles (ex.: `soma(2, 3)` retorna `5`).
- Funciona com inteiros, negativos e decimais seguindo a aritmética padrão do JavaScript (ex.: `soma(-1, 1)` retorna `0`).
- Testes automatizados obrigatórios, usando o runner nativo do Node (`node:test`), que cubram ao menos: dois positivos, um número negativo e zero. Os testes devem rodar com `npm test`.

Fica de fora:
- Validação de tipos ou erros para entradas que não sejam números (leitura assumida: a issue não pede isso).
- Somar mais de dois números, interface de linha de comando, rota HTTP ou interface visual.
- Recriar o servidor Express removido no commit 7c4356d.

## Why
O pedido cabe com folga em um PR pequeno, não toca dados, autenticação nem código compartilhado, e não conflita com nada no repositório: na branch `main` (local e remota, via `gh api .../contents`) só existem `.aes`, `.claude` e `README.md`. Como a issue é vaga, assumi a leitura mais simples, uma função `(a, b) => a + b` sem validação de entrada. Observação: o `README.md` ainda descreve `src/`, `test/` e Express, que foram removidos; corrigir isso não faz parte desta issue. O arquivo `contexto/contexto.md` não existe neste workspace, então a análise não usou critérios específicos do projeto além do README e do histórico do git.
