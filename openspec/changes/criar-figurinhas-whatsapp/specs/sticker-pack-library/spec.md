# Spec Delta

## Purpose

Permite ao usuário organizar suas figurinhas em pacotes nomeados, mantidos localmente no aparelho e disponíveis entre execuções do app.

## ADDED Requirements

### Requirement: Listar pacotes
O app SHALL exibir todos os pacotes salvos, cada um com nome, ícone e quantidade de figurinhas.

#### Scenario: Biblioteca vazia
- **WHEN** o usuário abre o app sem nenhum pacote salvo
- **THEN** o app mostra um estado vazio com a ação de criar um pacote

#### Scenario: Pacotes existentes
- **WHEN** o usuário abre o app com pacotes salvos
- **THEN** o app lista todos eles com nome, ícone e contagem de figurinhas

### Requirement: Criar, renomear e apagar pacotes
O app SHALL permitir criar um pacote com nome não vazio, renomeá-lo e apagá-lo.

#### Scenario: Criar pacote
- **WHEN** o usuário informa um nome não vazio e confirma
- **THEN** um pacote vazio aparece na lista

#### Scenario: Nome vazio
- **WHEN** o usuário tenta criar ou renomear um pacote com nome vazio ou só espaços
- **THEN** o app recusa a ação e mantém o estado anterior

#### Scenario: Apagar pacote
- **WHEN** o usuário confirma a exclusão de um pacote
- **THEN** o pacote e todas as suas figurinhas deixam de existir

### Requirement: Gerenciar figurinhas do pacote
O app SHALL exibir as figurinhas de um pacote em grade e permitir adicionar e remover figurinhas, respeitando o limite de 30 por pacote.

#### Scenario: Adicionar figurinha
- **WHEN** o usuário salva uma nova figurinha no editor a partir de um pacote
- **THEN** ela aparece na grade desse pacote

#### Scenario: Limite do pacote
- **WHEN** o pacote já tem 30 figurinhas
- **THEN** o app impede a criação de uma nova figurinha nele e informa o motivo

#### Scenario: Remover figurinha
- **WHEN** o usuário remove uma figurinha
- **THEN** ela some da grade e do armazenamento

### Requirement: Persistência local
O app SHALL manter pacotes e figurinhas no aparelho entre execuções, sem exigir rede ou conta.

#### Scenario: Reabrir o app
- **WHEN** o usuário fecha e reabre o app
- **THEN** todos os pacotes e figurinhas salvos continuam disponíveis e editáveis

### Requirement: Ícone do pacote
O app SHALL usar a primeira figurinha do pacote como ícone do pacote.

#### Scenario: Pacote com figurinhas
- **WHEN** o pacote tem ao menos uma figurinha
- **THEN** seu ícone é derivado da primeira figurinha

#### Scenario: Pacote vazio
- **WHEN** o pacote não tem figurinhas
- **THEN** o app mostra um ícone genérico
