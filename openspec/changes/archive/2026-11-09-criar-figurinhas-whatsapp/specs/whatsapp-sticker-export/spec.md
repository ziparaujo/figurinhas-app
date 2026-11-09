# Spec Delta

## Purpose

Converte um pacote de figurinhas para o formato aceito pelo WhatsApp e o entrega ao WhatsApp instalado no aparelho para ser adicionado.

## ADDED Requirements

### Requirement: Formato da figurinha
Cada figurinha exportada SHALL ser uma imagem WebP de 512x512 pixels com tamanho menor que 100KB, preservando a transparência.

#### Scenario: Figurinha dentro do limite
- **WHEN** o app exporta uma figurinha
- **THEN** o arquivo é WebP, 512x512 e menor que 100KB

#### Scenario: Imagem complexa
- **WHEN** a primeira codificação excede 100KB
- **THEN** o app reduz a qualidade até caber no limite

#### Scenario: Limite inalcançável
- **WHEN** nenhuma qualidade aceitável cabe em 100KB
- **THEN** a exportação falha com mensagem identificando a figurinha

### Requirement: Ícone do pacote
O app SHALL gerar o ícone do pacote como PNG de 96x96 pixels com menos de 50KB.

#### Scenario: Ícone gerado
- **WHEN** o app prepara um pacote para envio
- **THEN** o ícone é PNG, 96x96 e menor que 50KB

### Requirement: Pré-requisitos do pacote
O app SHALL permitir o envio somente de pacotes com 3 a 30 figurinhas, cada uma com 1 a 3 emojis.

#### Scenario: Pacote incompleto
- **WHEN** o pacote tem menos de 3 figurinhas
- **THEN** a ação de adicionar ao WhatsApp fica desabilitada e o app indica quantas faltam

#### Scenario: Pacote válido
- **WHEN** o pacote tem entre 3 e 30 figurinhas
- **THEN** a ação de adicionar ao WhatsApp fica habilitada

### Requirement: Envio ao WhatsApp
O app SHALL entregar o pacote ao WhatsApp pelo fluxo oficial de pasteboard e esquema de URL de pacote de figurinhas, mostrando o nome do pacote e o autor.

#### Scenario: Envio com sucesso
- **WHEN** o usuário aciona "Adicionar ao WhatsApp" num pacote válido com o WhatsApp instalado
- **THEN** o WhatsApp abre pedindo confirmação para adicionar o pacote

#### Scenario: WhatsApp não instalado
- **WHEN** o WhatsApp não está instalado
- **THEN** o app informa que o WhatsApp é necessário e não altera o pacote

#### Scenario: Falha na exportação
- **WHEN** a geração dos arquivos falha
- **THEN** o app mostra o erro e não abre o WhatsApp
