DECISION: ACCEPT
RISK: low
SURFACES: none
RESCOPED: no
ROUTE: feature

## Summary
- O pedido é claro: uma função JavaScript que recebe dois números e devolve a soma
- Não há duplicata: a busca por "soma" e "sum" em issues e PRs (todos os estados) retorna só esta issue
- Não existe código de soma no repositório hoje
- Cabe em um PR pequeno, com testes automatizados

## Scope
Criar uma função JavaScript que recebe dois números e devolve a soma deles, usando a aritmética padrão do JavaScript, sem arredondar. Ela deve ser exportável para outros módulos e vir com testes automatizados que cubram inteiros, negativos, zero e decimais (por exemplo, `0.1 + 0.2` segue o comportamento nativo).
Leitura adotada: a issue não diz o que fazer com entradas que não são números. Como a função existe para somar números, a especificação deve definir uma validação simples (rejeitar valores que não sejam números, com erro claro) e documentar essa escolha.
Fora do escopo: CLI, interface web ou endpoint HTTP, outras operações (subtração etc.), somar mais de dois números e precisão decimal arbitrária.

## Why
O repositório atual não versiona nenhum arquivo de aplicação (`git ls-files` vazio, nenhum `.js` na árvore). O app Express do PR #2 foi removido no commit 7c4356d, e o commit d7f7323 só trouxe documentação de PRD, sem código. Por isso não há nada a duplicar nem código compartilhado em risco. O pedido é contido e fácil de verificar com testes. A única lacuna (entradas inválidas) tem uma resposta sensata que pode ficar registrada na especificação, sem precisar bloquear o trabalho com uma pergunta.
