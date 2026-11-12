## Rodada 1

### Q1. Como a soma de decimais deve se comportar (ex.: 0.1 + 0.2 resulta em 0.30000000000000004 na aritmética padrão do JavaScript)?
Por que importa: define a regra de negócio e os casos de borda das user stories de decimais.
Recomendação: A — o intake já fixou "aritmética padrão do JavaScript"; é o mais simples e sem surpresa para quem conhece a linguagem.
- A) Aritmética padrão do JavaScript, sem arredondamento (0.1 + 0.2 = 0.30000000000000004)
- B) Arredondar o resultado para eliminar o ruído de ponto flutuante (0.1 + 0.2 = 0.3)
- C) Outra — descreva

### Q2. Qual nome o usuário (quem importa a função) deve usar para ela?
Por que importa: o nome faz parte do contrato público e aparece nos critérios de aceite e nos testes.
Recomendação: A — `soma`, igual ao exemplo do intake e ao idioma da issue.
- A) `soma`
- B) `sum`
- C) Outra — descreva
