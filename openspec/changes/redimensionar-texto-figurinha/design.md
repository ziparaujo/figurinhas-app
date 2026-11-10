# Design

## Context

O texto é desenhado por `OutlinedText` com `fontSize = 72` fixo e contorno de 16 cópias deslocadas, e é usado tanto no editor quanto na renderização final via `StickerCanvasView`. No editor, o texto tem uma área de toque transparente de 400x140 com `highPriorityGesture` de arrasto, e o canvas inteiro tem um `MagnifyGesture` (`simultaneousGesture`) que escala a foto. Motivação em `proposal.md`; requisitos nas specs.

## Goals / Non-Goals

**Goals:**
- Pinça sobre o texto escala o texto e nunca a foto ao mesmo tempo.
- O resultado salvo é idêntico à prévia, inclusive o contorno.
- Regra de alvo testável sem UI.

**Non-Goals:**
- Rotação, slider ou botões de tamanho, múltiplos textos.
- Medir o texto real para a área de toque (a área segue aproximada, como hoje).

## Decisions

**1. `textScale` no `StickerEditorState`, com `textScaleRange` (0,4 a 3) e `setTextScale(_:)` que faz clamp**, no mesmo padrão de `zoomRange` e `setZoom`. O `canvas` repassa `textScale` à `StickerCanvasView`.

**2. Escalar com `scaleEffect` sobre o `OutlinedText`, não alterando `fontSize`.** Mudar a fonte esbarraria em `minimumScaleFactor(0.3)`, `lineLimit(2)` e na largura máxima de 90%: o texto pararia de crescer ao chegar no limite do layout. Com `scaleEffect` o texto e o contorno (copias deslocadas) escalam juntos, sem reflow, e `ImageRenderer` reproduz o mesmo resultado. O `scaleEffect` fica antes do `.position(textPosition)`, para escalar em torno do centro do texto. Texto grande demais pode sair do canvas e é cortado pelo `.clipped()` existente; é aceitável e o limite máximo de 3x contém isso. Alternativa: mudar `fontSize`, descartada pelo motivo acima.

**3. Um único `MagnifyGesture` no canvas, com decisão de alvo no início.** Remove-se a ideia de um segundo gesto de pinça no overlay do texto, que dispararia junto com o do pai. No primeiro `onChanged` de cada gesto, o ponto `startLocation` (centro dos dedos) é testado com `state.isOnText(_:)`; o resultado vira `@State pinchTarget` (`.text` ou `.photo`) e fica travado até `onEnded`, quando é zerado. Cada alvo usa sua própria escala base (`baseZoom` e novo `baseTextScale`), atualizada no fim do gesto. Se não há texto, o alvo é sempre a foto.

**4. Teste de acerto em coordenadas do canvas.** `isOnText(_ point:)` retorna se o ponto está no retângulo centrado em `textPosition` com tamanho `400x140` multiplicado por `textScale`, a mesma área aproximada que o overlay usa hoje. O `startLocation` precisa estar em pontos do canvas (512). Como o gesto fica antes do `scaleEffect(scale)` da view, espera-se que o espaço local já seja o do canvas; isso deve ser conferido na primeira tarefa de UI, dividindo por `scale` se não for.

**5. A área de toque do arrasto do texto acompanha a escala**, usando o mesmo retângulo de `isOnText`, para que arrastar e pinçar considerem a mesma região.

## Risks / Trade-offs

- [O espaço de coordenadas de `startLocation` pode vir escalado] → conferir no simulador e dividir por `scale` se necessário; a lógica de decisão fica em `isOnText`, testada com pontos em coordenadas do canvas.
- [Área de toque aproximada: texto curto e pequeno tem retângulo bem maior que as letras] → aceito, igual ao arrasto atual; mitigação futura seria medir o texto.
- [Arrasto de um dedo do texto e pinça de dois dedos competirem no mesmo toque] → o arrasto do texto já é `highPriorityGesture`; validar manualmente que começar com dois dedos sobre o texto não move o texto.
- [Texto muito ampliado sai do canvas] → limite máximo de 3x e corte pelo canvas.
