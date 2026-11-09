# Proposal

## Why

Criar figurinhas para WhatsApp no iPhone hoje exige apps de terceiros cheios de anúncios ou assinatura. Quero um app pessoal e simples: escolher uma foto, ajustar o enquadramento, escrever um texto e adicionar o pacote ao WhatsApp. O projeto Xcode é apenas o template vazio, então esta é a change que cria o app.

## What Changes

- Biblioteca de pacotes de figurinhas (criar, renomear, apagar) com persistência local.
- Editor de figurinha: foto da galeria, pan e zoom num canvas quadrado, um único texto com estilo fixo e um emoji.
- Exportação de cada figurinha em WebP de 512x512 com menos de 100KB, e do ícone do pacote em PNG 96x96.
- Envio do pacote ao WhatsApp pelo fluxo oficial de pasteboard e esquema de URL `whatsapp://stickerPack`.
- Fora de escopo: figurinhas animadas, remoção de fundo, vários textos, múltiplos estilos de texto, reeditar figurinhas já salvas (v2), publicação na App Store, backend e sincronização.

## Capabilities

### New Capabilities
- `sticker-pack-library`: gerenciamento e persistência local de pacotes e das figurinhas dentro deles.
- `sticker-editor`: criação e edição de uma figurinha a partir de uma foto, com enquadramento, texto e emoji.
- `whatsapp-sticker-export`: geração dos arquivos no formato exigido pelo WhatsApp e envio do pacote ao app.

### Modified Capabilities

## Impact

- Código: o alvo `stickers` (SwiftUI) deixa de ser o template e ganha modelos, telas e serviços.
- Dependência nova: um encoder WebP via Swift Package Manager, pois o ImageIO do iOS não codifica WebP.
- Configuração: `LSApplicationQueriesSchemes` com `whatsapp` no Info.plist.
- Testes: o envio ao WhatsApp só pode ser validado num iPhone físico com WhatsApp instalado.
