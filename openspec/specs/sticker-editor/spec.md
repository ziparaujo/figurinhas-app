# sticker-editor Specification

## Purpose

Permite criar e editar uma figurinha a partir de uma foto da galeria, ajustando o enquadramento num canvas quadrado e sobrepondo um texto de estilo fixo.

## Requirements

### Requirement: Escolher foto
O editor SHALL permitir escolher uma foto da galeria do aparelho como base da figurinha.

#### Scenario: Foto escolhida
- **WHEN** o usuário seleciona uma foto
- **THEN** ela aparece no canvas quadrado do editor

#### Scenario: Seleção cancelada
- **WHEN** o usuário fecha o seletor sem escolher foto
- **THEN** o editor permanece sem foto e nada é salvo

### Requirement: Enquadrar a foto
O editor SHALL permitir mover e ampliar ou reduzir a foto dentro do canvas por gestos.

#### Scenario: Mover e dar zoom
- **WHEN** o usuário arrasta ou faz o gesto de pinça sobre a foto
- **THEN** a foto se move e muda de escala dentro do canvas

#### Scenario: Foto menor que o canvas
- **WHEN** a foto não cobre todo o canvas
- **THEN** as áreas descobertas permanecem transparentes na figurinha final

### Requirement: Texto único de estilo fixo
O editor SHALL permitir um único texto sobre a foto, sempre com fonte grossa, cor branca e contorno preto, e permitir posicioná-lo no canvas.

#### Scenario: Escrever texto
- **WHEN** o usuário digita um texto
- **THEN** ele aparece sobre a foto no estilo fixo

#### Scenario: Reposicionar texto
- **WHEN** o usuário arrasta o texto
- **THEN** ele se move e permanece dentro dos limites do canvas

#### Scenario: Sem texto
- **WHEN** o campo de texto está vazio
- **THEN** a figurinha é salva sem texto

### Requirement: Emoji da figurinha
O editor SHALL associar um emoji a cada figurinha, usando 😀 como padrão.

#### Scenario: Emoji padrão
- **WHEN** o usuário salva uma figurinha sem escolher emoji
- **THEN** a figurinha fica associada a 😀

### Requirement: Salvar figurinha
O editor SHALL salvar no pacote de origem a figurinha pronta, com a imagem final de 512x512 e o emoji. A foto original e os parâmetros de edição NÃO SHALL ser mantidos.

#### Scenario: Salvar
- **WHEN** o usuário confirma com uma foto escolhida
- **THEN** a figurinha pronta é adicionada ao pacote

#### Scenario: Salvar sem foto
- **WHEN** o usuário tenta salvar sem foto
- **THEN** o app impede o salvamento

#### Scenario: Imagem igual à pré-visualização
- **WHEN** a figurinha é salva
- **THEN** a imagem salva reproduz a pré-visualização do editor, incluindo o contorno do texto
