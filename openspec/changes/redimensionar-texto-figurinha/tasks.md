# Tasks

## 1. Estado e renderização

- [x] 1.1 Adicionar `textScaleRange`, `textScale` e `setTextScale(_:)` com clamp ao `StickerEditorState`, e testes em `EditorTests` que verificam o clamp nos dois limites
- [x] 1.2 Adicionar `isOnText(_:)` ao `StickerEditorState` (retângulo 400x140 vezes `textScale` centrado em `textPosition`, falso sem texto) e testes com pontos dentro, fora e na borda, com escalas diferentes
- [x] 1.3 Aplicar `textScale` ao `OutlinedText` via `scaleEffect` antes do `position` na `StickerCanvasView`, repassando-o pelo `canvas` do state, e teste de renderização que confere que o texto com escala 2 cobre mais pixels brancos que com escala 1 e mantém o contorno preto

## 2. Gestos no editor

- [x] 2.1 Trocar o `photoZoom` por um `MagnifyGesture` que decide o alvo (texto ou foto) no início por `isOnText(startLocation)`, trava o alvo até o fim e usa `baseTextScale` e `baseZoom`; verificar no simulador que a pinça sobre o texto não muda a foto e fora do texto não muda o texto
- [x] 2.2 Conferir no simulador o espaço de coordenadas de `startLocation` (se vem em pontos do canvas ou da tela) e ajustar a conversão por `scale`; verificar que o acerto coincide com a área do texto em telas de tamanhos diferentes
- [x] 2.3 Fazer a área de toque do arrasto do texto usar o mesmo retângulo escalado de `isOnText`; verificar que com o texto ampliado ou reduzido o arrasto continua funcionando e que começar com dois dedos sobre o texto não o move
- [x] 2.4 Verificar no simulador os cenários da spec: aumentar, diminuir, limites, alvo travado ao sair da área, segunda pinça partindo do tamanho atual e salvar com tamanho igual ao da prévia

## Workflow follow-up

- Arquivar a change depois da revisão.
