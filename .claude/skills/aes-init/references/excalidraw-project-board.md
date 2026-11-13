# Formato — `spec-project.excalidraw` e `design-system.excalidraw`

Adaptação do formato de elemento já definido em `aes-create-excalidraw` para
o caso de uso desta skill: em vez de jornada/camadas/regras extraídas de um
PRD, `aes-init` gera até dois boards `.excalidraw` separados, cada um
extraído do que já foi escrito em outro arquivo desta mesma skill — nunca
inventa módulo, tabela, cor ou componente novo aqui, é só a versão editável
do que a fonte já confirmou:

- **`spec-project.excalidraw`** (sempre, se houver fonte) — dois diagramas,
  extraídos de `diagrams/geral.modulos.md` e `diagrams/geral.banco.md`.
- **`design-system.excalidraw`** (condicional) — três blocos de conteúdo,
  extraídos de `_design-system.md`.

<HARD-GATE>
Todo elemento PRECISA ter o conjunto completo de campos-base abaixo — não só
os visuais (`x`/`y`/`width`/`height`/`strokeColor`). O visualizador chama a
API imperativa `updateScene` do Excalidraw diretamente
(`frontend/public/excalidraw/index.js`), que **não** roda a normalização
`restoreElements`/`convertToExcalidrawElements`. Um elemento incompleto não
gera erro nenhum — ele silenciosamente não renderiza (formas somem, texto
não aparece) e trava a edição (clique/seleção lança exceção interna ao
acessar um campo ausente, ex. `boundElements`/`groupIds` undefined). Isso já
quebrou em produção duas vezes por causa disso — sempre inclua todos os
campos, nunca escreva um elemento "minimalista só com o visual".
</HARD-GATE>

## Conteúdo de `spec-project.excalidraw` (dois diagramas)

1. **Mapa de módulos** — mesma informação de `diagrams/geral.modulos.md`:
   uma caixa por módulo/sistema real, agrupadas visualmente em duas colunas
   ou faixas (Backend / Frontend), com as mesmas setas de dependência
   confirmadas (nunca mais setas do que o Mermaid já validou).
2. **Visão geral do banco** — uma caixa por tabela real (nome da tabela +
   lista dos nomes de campo, sem detalhar tipo/constraint — isso fica no
   `geral.banco.md` Mermaid, que é a fonte de verdade completa), com uma
   linha simples entre tabelas que têm relação de FK — sem cardinalidade
   detalhada no desenho (o board é para discussão em time, não para leitura
   automática).

Dispor os dois diagramas lado a lado ou um abaixo do outro, com espaço
suficiente para não sobrepor.

## Conteúdo de `design-system.excalidraw` (board separado, condicional)

Gerado só quando `_design-system.md` foi gerado (ver `SKILL.md`) — extraído
do que já foi escrito lá, nunca inventa cor/fonte/componente que aquele
arquivo não tenha confirmado. Nota: `_design-system.md` já embute dois
blocos Mermaid inline (paleta de cores como swatches reais, componentes &
ícones como boxes rotulados — ver item 2 e item 6 de `SKILL.md`) que
renderizam direto no bloco "Design / Brand Style Guide" da pipeline, sem
precisar abrir este arquivo. Isso não torna este board redundante: é a
única versão que inclui a escala tipográfica como amostra de texto real e a
única que o time pode editar — o Mermaid é gerado de novo a cada regravação
de `_design-system.md`, o Excalidraw nunca é sobrescrito automaticamente
depois de criado (ver "Regra de não-sobrescrita" abaixo). Board próprio, não um frame extra dentro de
`spec-project.excalidraw` — os dois têm a mesma regra de nunca sobrescritos
automaticamente, e misturar os dois num único arquivo faria uma edição
manual num board arriscar sobrescrever trabalho manual no outro. Três
blocos de conteúdo, dispostos lado a lado ou um abaixo do outro:

1. **Paleta de cores** — um swatch (retângulo preenchido com a cor
   resolvida) por token de `_design-system.md`, com um texto rotulando o
   nome do token (ex. `--primary`) logo abaixo ou dentro do swatch. Só os
   tokens que `_design-system.md` de fato listou — nenhum inventado para
   "completar" a paleta.
2. **Escala tipográfica** — uma amostra de texto por entrada da escala
   tipográfica confirmada (ex. um bloco de texto no tamanho/peso real,
   rotulado com o nome do estilo se houver um, como "heading-lg" ou
   "body-sm"). Sem escala tipográfica confirmada → esta seção não entra no
   board.
3. **Componentes & ícones** — um bloco retangular rotulado por componente
   de UI compartilhado e por ícone do icon set, ambos listados em
   `_design-system.md`. Não desenha o componente/ícone visualmente (isso é
   trabalho de design, fora do escopo de um scan automatizado) — só o nome
   rotulado, agrupado por categoria (componentes / ícones) se a lista for
   grande o suficiente para justificar o agrupamento.

## Formato do arquivo `.excalidraw`

A estrutura de arquivo, os campos-base, os campos extras por tipo e o
script de validação abaixo são **os mesmos para os dois arquivos**
(`spec-project.excalidraw` e `design-system.excalidraw`) — nenhuma regra
nova de formato para o board de design system, só um conteúdo diferente
usando os mesmos tipos de elemento (`rectangle`, `text`, eventualmente
`frame` para separar as três seções).

```json
{ "type": "excalidraw", "version": 2, "source": "aes-init",
  "elements": [ /* ver campos abaixo */ ], "appState": { "viewBackgroundColor": "#ffffff" }, "files": {} }
```

Campos-base — todo elemento, qualquer tipo:

```json
{
  "angle": 0, "strokeColor": "#1e1e1e", "backgroundColor": "transparent",
  "fillStyle": "solid", "strokeWidth": 1, "strokeStyle": "solid",
  "roughness": 1, "opacity": 100, "roundness": null,
  "groupIds": [], "frameId": null, "boundElements": [],
  "seed": 1, "version": 1, "versionNonce": 1, "index": null,
  "isDeleted": false, "updated": 0, "link": null, "locked": false
}
```

Campos extras por tipo, além dos campos-base:

- **frame**: `"name": "<título do diagrama>"` — ex. "Mapa de Módulos", "Visão Geral do Banco".
- **rectangle**: nenhum extra (ajuste `strokeColor`/`backgroundColor`/`roundness` conforme a cor e o arredondamento desejados; `roundness: {"type": 3}` para cantos arredondados — use uma cor por camada/grupo para diferenciar Backend de Frontend, e outra cor para caixas de tabela).
- **text**: `"text"`, `"fontSize"`, `"fontFamily": 1`, `"textAlign": "left"`, `"verticalAlign": "top"`, `"containerId": null` (ou o `id` do retângulo, se o texto vive dentro de uma caixa), `"originalText"` (igual a `text`), `"lineHeight": 1.25`, `"autoResize": true`.
- **arrow** (conecta módulo-frontend → módulo-backend, ou tabela → tabela relacionada): `"points": [[0,0],[dx,dy]]` (relativo a `x`/`y` do próprio elemento), `"lastCommittedPoint": null`, `"startBinding": null`, `"endBinding": null`, `"startArrowhead": null`, `"endArrowhead": "arrow"`.

`index: null` é válido — o `updateScene` roda `syncInvalidIndices` e atribui
o índice fracionário real ao carregar. `seed`/`versionNonce`/`updated` podem
ser qualquer placeholder estável.

### Regra extra — binding de texto dentro de retângulo

Se um texto vive dentro de uma caixa (`containerId` apontando para o
`id` do retângulo), o **retângulo** precisa listar esse texto no seu próprio
`boundElements`: `"boundElements": [{"id": "<id-do-texto>", "type": "text"}]`.
Um `containerId` declarado só do lado do texto, sem o retângulo listar de
volta, é a falha mais comum e mais silenciosa deste formato — sempre grava
os dois lados juntos.

Da mesma forma, toda seta com `startBinding`/`endBinding` referencia um
`elementId` que **existe de fato** na lista de `elements` — nunca um id
solto.

## Script de validação (rodar antes de escrever o arquivo)

```bash
python3 -c "
import json, sys
data = json.load(open(sys.argv[1]))
base = {'id','type','x','y','width','height','angle','strokeColor','backgroundColor','fillStyle',
        'strokeWidth','strokeStyle','roughness','opacity','groupIds','frameId','roundness','seed',
        'version','versionNonce','index','isDeleted','boundElements','updated','link','locked'}
extra = {
    'frame': {'name'},
    'text': {'text','fontSize','fontFamily','textAlign','verticalAlign','containerId','originalText','lineHeight','autoResize'},
    'arrow': {'points','lastCommittedPoint','startBinding','endBinding','startArrowhead','endArrowhead'},
}
by_id = {e['id']: e for e in data['elements']}
bad = False
for e in data['elements']:
    need = base | extra.get(e['type'], set())
    missing = need - set(e.keys())
    if missing:
        bad = True
        print('MISSING', e.get('id'), missing)
    if e['type'] == 'text' and e.get('containerId'):
        container = by_id.get(e['containerId'])
        if container is None:
            bad = True
            print('BROKEN_CONTAINER_REF', e['id'], e['containerId'])
        elif not any(b.get('id') == e['id'] for b in container.get('boundElements') or []):
            bad = True
            print('MISSING_BACKREF', e['id'], 'not in boundElements of', e['containerId'])
    if e['type'] == 'arrow':
        for key in ('startBinding', 'endBinding'):
            binding = e.get(key)
            if binding and binding.get('elementId') not in by_id:
                bad = True
                print('BROKEN_ARROW_BINDING', e['id'], key, binding.get('elementId'))
print('FAIL' if bad else 'OK')
" \"$ARQUIVO\"
```

Falha em qualquer checagem (`MISSING`, `BROKEN_CONTAINER_REF`,
`MISSING_BACKREF`, `BROKEN_ARROW_BINDING`) → corrige o elemento apontado e
roda de novo antes de gravar; nunca entrega um board que falhou na
validação.

## Regra de não-sobrescrita

Vale para os dois arquivos, cada um contra sua própria fonte:

- `spec-project.excalidraw` nunca é regravado automaticamente, mesmo quando
  o código-fonte muda e os Mermaid (`geral.modulos.md`/`geral.banco.md`) são
  regenerados.
- `design-system.excalidraw` nunca é regravado automaticamente, mesmo
  quando `_design-system.md` é regenerado por mudança nos tokens/tema.

Ambos são presumidos editados pelo time a qualquer momento depois de
criados. Só são (re)gerados quando o usuário pede explicitamente ("recria o
excalidraw", "gera de novo do zero") e, mesmo assim, pergunta confirmação
antes de sobrescrever um já existente.
