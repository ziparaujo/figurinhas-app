# Tasks

## 1. Spike do WebP e do envio ao WhatsApp

- [ ] 1.1 Adicionar a biblioteca WebP via SPM e verificar que o projeto compila para dispositivo e simulador
- [ ] 1.2 Criar o protocolo `WebPEncoding` e uma implementação, com teste unitário que codifica uma imagem 512x512 e confirma que o resultado decodifica de volta como WebP
- [ ] 1.3 Adicionar `whatsapp` em `LSApplicationQueriesSchemes` no Info.plist e verificar que `canOpenURL` retorna verdadeiro num iPhone com WhatsApp
- [ ] 1.4 Gerar 3 figurinhas de teste com o encoder da 1.2 (512x512, menos de 100KB, uma delas com transparência), enviá-las ao WhatsApp num iPhone físico e verificar que o WhatsApp pede confirmação e exibe as 3 figurinhas corretamente depois de adicionadas
- [ ] 1.5 Registrar o resultado do spike (biblioteca escolhida, qualidade usada, tamanho dos arquivos) no `design.md`; se o WhatsApp rejeitar o WebP, trocar a biblioteca da 1.1 e repetir 1.2 a 1.4 antes de seguir para o grupo 2

## 2. Modelo e persistência

- [ ] 2.1 Criar os modelos SwiftData `StickerPack` e `Sticker` com relação em cascata, e verificar com teste que apagar um pacote remove suas figurinhas
- [ ] 2.2 Criar o armazenamento de arquivos para o PNG final da figurinha, e verificar com teste que gravar, ler e apagar funcionam
- [ ] 2.3 Verificar com teste que pacotes e figurinhas gravados sobrevivem à recriação do container

## 3. Biblioteca de pacotes

- [ ] 3.1 Implementar a lista de pacotes com estado vazio e verificar na tela com e sem pacotes
- [ ] 3.2 Implementar criar, renomear e apagar pacote, recusando nome vazio, e verificar com teste de validação e na tela
- [ ] 3.3 Implementar a grade de figurinhas do pacote, com remoção e limite de 30, e verificar o bloqueio ao chegar em 30
- [ ] 3.4 Implementar o ícone do pacote derivado da primeira figurinha, com ícone genérico para pacote vazio, e verificar nos dois casos

## 4. Editor de figurinha

- [ ] 4.1 Integrar o `PhotosPicker` e exibir a foto num canvas quadrado, verificando que cancelar a seleção não salva nada
- [ ] 4.2 Implementar pan e zoom da foto e verificar que áreas descobertas ficam transparentes na imagem renderizada
- [ ] 4.3 Implementar na `StickerCanvasView` o texto único de estilo fixo com contorno por cópias deslocadas, arrastável e limitado ao canvas, e verificar com preview e teste do parâmetro de posição
- [ ] 4.4 Usar a mesma `StickerCanvasView` (exibida com `scaleEffect` no editor) na renderização com `ImageRenderer` a `scale = 1`, e verificar com teste que a imagem sai 512x512, com pixels pretos ao redor do texto branco e igual ao PNG de referência dentro da tolerância
- [ ] 4.5 Implementar salvar a figurinha pronta, com emoji padrão 😀 e bloqueio sem foto, e verificar que ela aparece na grade do pacote e que sem foto o salvamento é recusado

## 5. Exportação para o WhatsApp

- [ ] 5.1 Implementar `StickerPackExporter` com figurinha WebP 512x512 e ícone PNG 96x96, verificando com testes os formatos e dimensões
- [ ] 5.2 Implementar a busca de qualidade abaixo de 100KB e o erro identificando a figurinha, verificando com teste usando uma imagem de alta entropia
- [ ] 5.3 Implementar a validação de 3 a 30 figurinhas e 1 a 3 emojis e verificar com testes de borda (2, 3, 30, 31)
- [ ] 5.4 Implementar `WhatsAppSender` com pasteboard e abertura da URL, tratando WhatsApp ausente e falha de exportação, e verificar as mensagens de erro
- [ ] 5.5 Ligar o botão "Adicionar ao WhatsApp" no detalhe do pacote, desabilitado com menos de 3 figurinhas e indicando quantas faltam, e verificar nos dois estados

## 6. Integração

- [ ] 6.1 Percorrer o fluxo completo num iPhone físico (criar pacote, 3 figurinhas com foto e texto, enviar) e verificar que as figurinhas aparecem no WhatsApp
- [ ] 6.2 Substituir o `ContentView` do template pela navegação real e verificar que o app abre direto na lista de pacotes
