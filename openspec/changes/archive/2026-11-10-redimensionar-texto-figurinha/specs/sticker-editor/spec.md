# Spec Delta

## MODIFIED Requirements

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
