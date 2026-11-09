# Design

## Context

O repositório contém só o template Xcode (`stickers/stickers/ContentView.swift` e `stickersApp.swift`), em SwiftUI. Não há código a preservar. Motivação em `proposal.md`; requisitos nas specs.

O iOS não tem API de importação de figurinhas como o ContentProvider do Android. O WhatsApp lê um payload JSON do `UIPasteboard` (tipo `net.whatsapp.third-party.sticker-pack`) quando o app abre `whatsapp://stickerPack`. O payload tem identificador, nome, autor, ícone em base64 e a lista de figurinhas com imagem em base64 e emojis. Os limites numéricos vêm da documentação do WhatsApp e devem ser conferidos no repositório oficial `WhatsApp/stickers` antes de implementar.

## Goals / Non-Goals

**Goals:**
- App 100% local, sem backend, sem conta, para uso pessoal.
- O que o usuário vê no canvas é exatamente o que vira figurinha.
- Camada de exportação isolada da UI e testável sem WhatsApp.

**Non-Goals:**
- Animação, remoção de fundo, vários textos, sincronização, App Store.
- Reeditar uma figurinha já salva (v2): só o resultado final é guardado, não a foto original nem os parâmetros de edição.
- Abstrair para outros mensageiros.

## Decisions

**1. SwiftData para persistência.** `StickerPack` (id, nome, autor, data) tem relação de cascata com `Sticker` (id, emoji, ordem, nome do arquivo). O PNG final de 512x512 fica em arquivo no diretório do app e o banco guarda só o nome do arquivo. A foto original e os parâmetros de edição não são persistidos. Alternativa: Core Data, descartada por mais boilerplate; JSON em arquivo, descartado por exigir sincronizar relações à mão.

**2. Canvas único em SwiftUI e `ImageRenderer` para renderizar.** Uma única `StickerCanvasView` com tamanho lógico fixo de 512x512 pt serve ao editor e à renderização final, com `DragGesture`, `MagnifyGesture` e o texto. No editor ela é exibida reduzida com `scaleEffect`, sem reflow de layout, então fonte, contorno e posição mantêm as mesmas proporções. Na exportação, o `ImageRenderer` renderiza essa mesma view com `scale = 1`, saindo em 512x512 reais independente do scale da tela. Alternativa: desenhar à parte com Core Graphics, descartada porque duplicaria o layout e correria o risco de o resultado divergir da tela.

**3. Contorno do texto por cópias deslocadas.** O SwiftUI não tem stroke para `Text`. O contorno é feito empilhando 16 cópias do texto em preto, deslocadas ao longo de um círculo de raio `0,06 × tamanho da fonte`, com o texto branco por cima. O resultado é determinístico e não depende de sombras, que o `ImageRenderer` pode tratar de forma diferente. A fonte é a do sistema (`.system`, peso `.black`), para não haver fonte ausente. O texto tem largura máxima de 90% do canvas e `minimumScaleFactor` para não vazar, e a posição é guardada em coordenadas do canvas de 512 pt. Como editor e render usam a mesma `StickerCanvasView` (decisão 2), o contorno é o mesmo nos dois. Verificação: teste que renderiza a view com `ImageRenderer` e confere as dimensões, a presença de pixels pretos ao redor dos brancos e a comparação com um PNG de referência com tolerância. Alternativas: stroke pelo caminho dos glifos do Core Text, preciso mas com bem mais código; `.shadow` empilhado, descartado por depender do renderer.

**4. Encoder WebP via SPM.** O ImageIO decodifica WebP mas não codifica. Será escolhida uma biblioteca baseada em libwebp (candidatas: `SDWebImageWebPCoder`, `swift-webp`); a decisão final é a primeira tarefa, num spike. O encoder fica atrás de um protocolo `WebPEncoding` para trocar a biblioteca sem tocar no resto.

**5. Compressão por busca de qualidade.** Começa em qualidade alta e reduz em passos até ficar abaixo de 100KB, com piso mínimo. Se não couber, falha com erro que identifica a figurinha. Alternativa: qualidade fixa, descartada por estourar o limite em fotos detalhadas.

**6. Serviço de exportação puro.** `StickerPackExporter` recebe um pacote e devolve o payload (dados e metadados) sem tocar em UI ou pasteboard. Um `WhatsAppSender` pequeno grava o pasteboard (com expiração curta, na ordem do minuto) e chama `open`. Isso permite testar limites e formato em testes unitários.

**7. Emoji fixo em 😀 na v1.** O modelo já guarda o emoji por figurinha, então um seletor depois não exige migração.

**8. Ícone do pacote derivado da primeira figurinha**, reduzido a 96x96 PNG na exportação. Evita uma tela extra de escolha de ícone.

## Risks / Trade-offs

- [Encoder WebP incompatível ou rejeitado pelo WhatsApp] → spike inicial que exporta um pacote real num iPhone antes de construir o resto.
- [Simulador sem WhatsApp] → o envio só é validável em aparelho físico; o restante é coberto por testes unitários do exportador.
- [Formato do pasteboard pode mudar sem aviso] → isolar em `WhatsAppSender` e conferir com o repositório oficial.
- [Fotos grandes consomem memória] → reduzir a foto ao carregar para uma dimensão máxima suficiente para o zoom e descartá-la após salvar.
- [Build com Apple ID gratuito expira em 7 dias] → aceitável para uso pessoal; reinstalar pelo Xcode.
- [Sem emoji editável, o WhatsApp sugere a figurinha para um único emoji] → aceito na v1, modelo já preparado.

## Resultado do spike (tarefas 1.1 a 1.5)

Validado em iPhone físico (iPhone 16) com WhatsApp instalado:

- **Biblioteca:** `Swift-WebP` 0.7.0 (produto `WebP`, baseado em libwebp 1.6.0), atrás do protocolo `WebPEncoding` (`LibWebPEncoder`). Preset `.picture`, qualidade 80.
- **Tamanhos:** figurinhas de teste com 2454, 1912 e 5420 bytes (imagens sintéticas, bem abaixo dos 100KB); ícone PNG 96x96 com 1896 bytes; payload do pasteboard com 16119 bytes.
- **Resultado:** `canOpenURL(whatsapp://)` retornou verdadeiro, o WhatsApp pediu confirmação e exibiu as 3 figurinhas corretamente, inclusive a com transparência. Não foi necessário trocar a biblioteca.
- **Não coberto pelo spike:** fotos reais detalhadas, que ainda exigem a busca de qualidade da decisão 5.
- **Payload conferido no repositório oficial `WhatsApp/stickers`:** `identifier`, `name`, `publisher` (obrigatório), `tray_image` (PNG base64) e `stickers[]` com `image_data` (WebP base64) e `emojis`. `name`, `publisher` e `identifier` têm no máximo 128 caracteres.
- **Autor do pacote (v1):** valor padrão "Rod", guardado no modelo do pacote. Sem tela para alterá-lo na v1; o modelo já permite editar depois.

## Notas da implementação

- **Cor dos PNGs do ícone:** o `UIGraphicsImageRenderer` usa por padrão a faixa de cor estendida em aparelhos com tela P3, e o PNG do ícone saiu com 16 bits por canal, passando dos 50KB no iPhone (o simulador não reproduz). `StickerPackExporter.resized` fixa `preferredRange = .standard` para gerar 8 bits por canal. Não há teste automatizado para isso, só a verificação em aparelho.
- **Limite de 128 caracteres:** o WhatsApp limita `name`, `publisher` e `identifier` a 128 caracteres. A exportação recusa o pacote com `ExportError.textTooLong` quando o nome ou o autor passa disso; o identificador é um UUID e não é afetado.
