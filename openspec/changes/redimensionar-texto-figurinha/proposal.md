# Proposal

## Why

Hoje o texto da figurinha tem tamanho fixo (72 pt). Quem escreve uma frase curta quer letras grandes, e quem escreve uma frase longa quer letras menores. O usuário já aprendeu a dar pinça na foto, então o mesmo gesto deveria funcionar no texto.

## What Changes

- O usuário passa a aumentar ou diminuir o texto com o gesto de pinça sobre ele.
- O alvo da pinça é decidido pelo ponto central dos dois dedos no início do gesto: sobre a área do texto, escala o texto; fora dela, escala a foto, como hoje. O alvo fica travado até o fim do gesto.
- O contorno preto escala junto com o texto, e a figurinha salva reproduz o tamanho visto no editor.
- O tamanho é limitado a uma faixa mínima e máxima.
- Fora de escopo: rotação do texto, seletor de tamanho por botão ou slider, mudar fonte ou cor.

## Capabilities

### New Capabilities

### Modified Capabilities
- `sticker-editor`: o requisito "Texto único de estilo fixo" passa a prever tamanho ajustável por pinça, e o requisito "Enquadrar a foto" passa a deixar claro que a pinça só age na foto quando o centro do gesto está fora do texto.

## Impact

- `stickers/stickers/Editor/StickerEditorState.swift`: novo `textScale` com limites e teste de acerto na área do texto.
- `stickers/stickers/Editor/StickerCanvasView.swift`: aplica a escala ao texto, para editor e renderização final.
- `stickers/stickers/Editor/StickerEditorView.swift`: gesto de pinça único com decisão de alvo, e área de toque do texto proporcional à escala.
- `stickers/stickersTests/EditorTests.swift`: novos testes.
- Sem dependências novas e sem mudança no modelo persistido.
