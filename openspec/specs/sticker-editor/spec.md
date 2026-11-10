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
O editor SHALL permitir mover e ampliar ou reduzir a foto dentro do canvas por gestos. A pinça SHALL agir na foto apenas quando o centro dos dedos, no início do gesto, estiver fora da área do texto.

#### Scenario: Mover e dar zoom
- **WHEN** o usuário arrasta ou faz o gesto de pinça sobre a foto, fora da área do texto
- **THEN** a foto se move e muda de escala dentro do canvas

#### Scenario: Foto menor que o canvas
- **WHEN** a foto não cobre todo o canvas
- **THEN** as áreas descobertas permanecem transparentes na figurinha final

#### Scenario: Pinça sobre o texto não mexe na foto
- **WHEN** o usuário faz a pinça com o centro dos dedos sobre a área do texto
- **THEN** a escala da foto permanece a mesma

### Requirement: Texto único de estilo fixo
O editor SHALL permitir um único texto sobre a foto, sempre com fonte grossa, cor branca e contorno preto, permitir posicioná-lo no canvas e permitir aumentar ou diminuir seu tamanho por pinça. O estilo é fixo; só o tamanho varia.

#### Scenario: Escrever texto
- **WHEN** o usuário digita um texto
- **THEN** ele aparece sobre a foto no estilo fixo

#### Scenario: Reposicionar texto
- **WHEN** o usuário arrasta o texto
- **THEN** ele se move e permanece dentro dos limites do canvas

#### Scenario: Sem texto
- **WHEN** o campo de texto está vazio
- **THEN** a figurinha é salva sem texto

#### Scenario: Aumentar o texto
- **WHEN** o usuário afasta os dedos com o centro do gesto sobre a área do texto
- **THEN** o texto e seu contorno crescem proporcionalmente e a foto não muda

#### Scenario: Diminuir o texto
- **WHEN** o usuário aproxima os dedos com o centro do gesto sobre a área do texto
- **THEN** o texto e seu contorno diminuem proporcionalmente e a foto não muda

#### Scenario: Alvo travado durante o gesto
- **WHEN** o centro dos dedos começa sobre o texto e sai da área dele durante a pinça
- **THEN** o gesto continua escalando o texto até os dedos serem levantados

#### Scenario: Limites de tamanho
- **WHEN** o usuário continua a pinça além do tamanho mínimo ou máximo permitido
- **THEN** o texto para de mudar de tamanho no limite

#### Scenario: Tamanho na figurinha salva
- **WHEN** o usuário salva a figurinha com o texto redimensionado
- **THEN** o texto aparece na imagem salva com o mesmo tamanho visto no editor

#### Scenario: Nova pinça parte do tamanho atual
- **WHEN** o usuário faz uma segunda pinça sobre o texto já redimensionado
- **THEN** a escala continua do tamanho atual, sem voltar ao padrão

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
